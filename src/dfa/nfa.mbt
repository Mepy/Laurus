///|
struct NState {
  mut token : Token? // 除了 token_union 外, 唯有 halting_state.token = Some(1)
  mut left : Array[CodePoint]
  mut right : Array[CodePoint]
  // 这里的 Index 是相对值，方便构造 NFA，例子见 NFA::string
  mut next : Array[Set[Index]]
  empty : Set[Index]
}

///|
fn NState::new(token? : Token) -> NState {
  { token, left: [], right: [], next: [], empty: Set::new() }
}

///|
/// 简并区间
fn NState::merge_range(self : NState) -> Unit {
  let len = self.next.length()
  if len <= 1 {
    return
  }
  let new_left = Array::new(capacity=len)
  let new_right = Array::new(capacity=len)
  let new_next = Array::new(capacity=len)
  new_left.push(self.left[0])
  new_right.push(self.right[0])
  new_next.push(self.next[0])
  for i in 1..<len {
    let new_i = new_next.length() - 1
    if new_right[new_i].to_int() + 1 == self.left[i].to_int() &&
      new_next[new_i] == self.next[i] {
      new_right[new_i] = new_right[i]
    } else {
      new_left.push(self.left[i])
      new_right.push(self.right[i])
      new_next.push(self.next[i])
    }
  }
  self.left = new_left
  self.right = new_right
  self.next = new_next
}

///|
/// 假定 next 非空且相同, 将区间取反
fn NState::not(self : NState) -> Unit {
  let len = self.next.length()
  let new_left = []
  let new_right = []
  let first_left = self.left[0]
  if first_left != MinCodePoint {
    new_left.push(MinCodePoint)
    new_right.push(first_left.prev()) // if 条件保证安全
  }

  // 空隙处理
  for i in 0..<(len - 1) {
    let gap_left = self.right[i].next()
    let gap_right = self.left[i + 1].prev()
    if gap_left < gap_right {
      new_left.push(gap_left)
      new_right.push(gap_right)
    }
  }
  let last_right = self.right[len - 1]
  if last_right != MaxCodePoint {
    new_left.push(last_right.next()) // if 条件保证安全
    new_right.push(MaxCodePoint)
  }
  let new_next = Array::makei(new_left.length(), _ => self.next[0].copy())
  self.left = new_left
  self.right = new_right
  self.next = new_next
}

///|
/// 没有重复元素时查找上确界的 Index
fn[T : Compare] supremum(array : Array[T], e : T) -> Index {
  let mut left = 0
  let mut right = array.length() - 1
  if left > right || array[right] < e {
    return -1
  }
  if array[left] >= e {
    return left
  }
  while right - left > 1 {
    let middle = (left + right) / 2
    if array[middle] < e {
      left = middle + 1 // 因为要找上界
    } else if e < array[middle] {
      right = middle
    } else {
      return middle
    }
  }
  right
}

///|
/// 没有重复元素时查找下确界的 Index
fn[T : Compare] infimum(array : Array[T], e : T) -> Index {
  let mut left = 0
  let mut right = array.length() - 1
  if left > right || array[left] > e {
    return -1
  }
  if array[right] <= e {
    return right
  }
  while right - left > 1 {
    let middle = (left + right) / 2
    if e < array[middle] {
      right = middle - 1 // 因为要找下界
    } else if array[middle] < e {
      left = middle
    } else {
      return middle
    }
  }
  left
}

///|
fn NState::insert_at(
  self : NState,
  i : Int,
  left : CodePoint,
  right : CodePoint,
  next : Set[Index],
) -> Unit {
  self.left.insert(i, left)
  self.right.insert(i, right)
  self.next.insert(i, next)
}

///|
fn NState::insert_push(
  self : NState,
  left : CodePoint,
  right : CodePoint,
  next : Set[Index],
) -> Unit {
  self.left.push(left)
  self.right.push(right)
  self.next.push(next)
}

///|
fn NState::insert(
  self : NState,
  left : CodePoint,
  right : CodePoint,
  next : Set[Index],
) -> Unit {
  let right_i = infimum(self.left, right)
  if right_i == -1 { // not_found -> right < self.left, 位于最左侧, 简单插入即可 
    return self.insert_at(0, left, right, next)
  }
  let left_i = supremum(self.right, left)
  if left_i == -1 { // not_found -> self.right < left, 位于最右侧, 简单插入即可
    return self.insert_push(left, right, next)
  }
  if right_i < left_i { // ..right_i [left, right] left_i.., 位于中间空隙, 简单插入即可
    return self.insert_at(left_i, left, right, next)
  }

  // range joint, split algorithm

  // 区间与右侧的重叠情况，处理完后使得 self.right[right_i] == right
  let old_right = self.right[right_i]
  if old_right < right { // old_right < right, 切出 [old_right+1, right] |-> next
    self.insert_at(
      right_i + 1,
      old_right.next(), // old_right+1 <= right 所以必然是合法的
      right,
      next.copy(),
    )
  } else if right < old_right { // right < old_right, 切出 [right+1, old_right] |-> self.next[right_i] 
    self.right[right_i] = right
    self.insert_at(
      right_i + 1,
      right.next(), // right+1 <= old_right 所以必然是合法的
      old_right,
      self.next[right_i].copy(),
    )
  }
  for i = right_i; left_i < i; i = i - 1 {
    // 合并重叠区间的值
    self.next[i] = self.next[i].union(next)

    // 检查前区间与当前区间之间的间隙
    let gap_left = self.right[i - 1].next()
    let gap_right = self.left[i].prev() // 因为 left_i < i，所以合法
    if gap_left <= gap_right { // 插入间隙区间（新值）
      self.insert_at(i, gap_left, gap_right, next.copy())
    }
  }

  // 区间与左侧的重叠情况，处理完后使得 self.left[left_i] == left
  let old_left = self.left[left_i]
  if left < old_left { // left < old_left, 新增 [left, old_left-1] |-> next
    self.next[left_i] = self.next[left_i].union(next)
    self.insert_at(left_i, left, old_left.prev(), next.copy())
  } else if old_left < left { // old_left < left, 
    // 合并 [left, ...] |-> self.next[left_i].union(next)
    // 切出 [old_left, left-1] |-> self.next[left_i]
    let old_next = self.next[left_i]
    self.left[left_i] = left
    self.next[left_i] = old_next.union(next)
    self.insert_at(left_i, old_left, left.prev(), old_next)
  } else { // 左边界对齐：直接合并值
    self.next[left_i] = self.next[left_i].union(next)
  }
}

///|
struct NFA {
  states : Array[NState]
}

///|
fn NFA::new(ranges : Array[(CodePoint, CodePoint)]) -> NFA {
  let initial_state = NState::new()
  let halting_state = NState::new(token=1)
  let states = [initial_state, halting_state]
  for r in ranges {
    let (left, right) = r
    let next = Set::new(capacity=1)
    next.add(1)
    initial_state.insert(left, right, next)
  }
  NFA::{ states, }
}

///|
/// 接受单字符
fn NFA::single(c : CodePoint) -> NFA {
  NFA::new([(c, c)])
}

///|
/// 接受单个区间
fn NFA::range(left : CodePoint, right : CodePoint) -> NFA {
  NFA::new([(left, right)])
}

///|
/// 接受多个区间 [A-Z0-9]
fn NFA::bor(ranges : Array[(CodePoint, CodePoint)]) -> NFA {
  NFA::new(ranges)
}

///|
/// 接受多个区间的取反 [^A-Z0-9]
fn NFA::bnot(ranges : Array[(CodePoint, CodePoint)]) -> NFA {
  let nfa = NFA::new(ranges)
  nfa.states[0].not()
  nfa
}

///|
/// 接受任意字符
fn NFA::any() -> NFA {
  NFA::new([(MinCodePoint, MaxCodePoint)])
}

///|
/// 接受空串
fn NFA::emp() -> NFA {
  let nfa = NFA::new([])
  nfa.states[0].empty.add(1)
  nfa
}

///|
/// nfa1 | nfa2 | ... | nfan
fn NFA::union(nfas : Array[NFA]) -> NFA {
  if nfas.length() == 0 {
    return NFA::new([])
  }
  let wrapper = NFA::new([])
  let initial_state = wrapper.states[0]
  let halting_state = wrapper.states[1]
  let halt_length = nfas.map(fn(nfa) {
    let length = nfa.states.length()
    let halt_state = nfa.states[length - 1]
    halt_state.token = None
    (halt_state, length)
  })
  let total = nfas
    .map(fn(nfa) -> Int { nfa.states.length() })
    .fold(init=0, Int::add)
  let halting_i = total + 1
  let states = [initial_state]
  for nfa in nfas {
    let nfa_init_i = states.length() // index of nfa.states[0] in states
    initial_state.empty.add(nfa_init_i)
    for s in nfa.states {
      states.push(s)
    }
    let nfa_len = nfa.states.length()
    let nfa_halt_state = nfa.states[nfa_len - 1]
    let nfa_halt_i = nfa_init_i + nfa_len - 1
    nfa_halt_state.empty.add(halting_i - nfa_halt_i)
    nfa_halt_state.token = None
  }
  states.push(halting_state)
  NFA::{ states, }
}

///|
/// 接受 nfa1·nfa2·...·nfan
fn NFA::seq(nfas : Array[NFA]) -> NFA {
  if nfas.length() == 0 {
    return NFA::emp()
  }
  let states = []
  let last_nfa_i = nfas.length() - 1
  for i in 0..<nfas.length() {
    let nfa = nfas[i]
    for s in nfa.states {
      states.push(s)
    }
    if i != last_nfa_i {
      let nfa_len = nfa.states.length()
      let nfa_halt_state = nfa.states[nfa_len - 1]
      nfa_halt_state.token = None
      nfa_halt_state.empty.add(1)
    }
  }
  NFA::{ states, }
}

///|
/// 接受 nfan·nfa(n-1)·...·nfa1
fn NFA::seq_rev(nfas : Array[NFA]) -> NFA {
  if nfas.length() == 0 {
    return NFA::emp()
  }
  NFA::seq(nfas.rev())
}

///|
/// nfa*
fn NFA::star(nfa : NFA) -> NFA {
  let wrapper = NFA::new([])
  let initial_state = wrapper.states[0]
  let halting_state = wrapper.states[1]
  let len = nfa.states.length()
  let states = Array::new(capacity=len + 2)
  let halting_i = len + 1
  initial_state.empty.add(1)
  initial_state.empty.add(halting_i - 0)
  let nfa_halt_i = len - 1
  let nfa_halt_state = nfa.states[nfa_halt_i]
  nfa_halt_state.token = None
  nfa_halt_state.empty.add(1)
  nfa_halt_state.empty.add(0 - nfa_halt_i)
  states.push(initial_state)
  for s in nfa.states {
    states.push(s)
  }
  states.push(halting_state)
  NFA::{ states, }
}

///|
/// nfa+
fn NFA::plus(nfa : NFA) -> NFA {
  let wrapper = NFA::new([])
  let initial_state = wrapper.states[0]
  let halting_state = wrapper.states[1]
  let len = nfa.states.length()
  let states = Array::new(capacity=len + 2)
  let halting_i = len + 1
  initial_state.empty.add(1)
  let nfa_halt_i = len - 1
  let nfa_halt_state = nfa.states[nfa_halt_i]
  nfa_halt_state.token = None
  nfa_halt_state.empty.add(1)
  nfa_halt_state.empty.add(0 - nfa_halt_i)
  states.push(initial_state)
  for s in nfa.states {
    states.push(s)
  }
  states.push(halting_state)
  NFA::{ states, }
}

///|
/// 接受字符串
fn NFA::string(str : String) -> NFA {
  let states = Array::new(capacity=str.length() + 1)
  for c in str {
    let state = NState::new()
    state.left.push(c)
    state.right.push(c)
    state.next.push(Set::from_array([1]))
    states.push(state)
  }
  let halting_state = NState::new(token=1)
  states.push(halting_state)
  NFA::{ states, }
}

///|
/// 接受反向字符串
fn NFA::string_rev(str : String) -> NFA {
  NFA::string(str.rev())
}

///|
/// 最后调用，合并具有不同 token 的 nfa
/// 因而 halting_state 有多个，且 token 均不同
fn NFA::token_union(nfas : Iter[NFA]) -> NFA {
  let initial_state = NState::new()
  let states = [initial_state]
  let mut cur : Index = 1
  for nfa in nfas {
    initial_state.empty.add(cur)
    let len = nfa.states.length()
    cur += len
    for s in nfa.states {
      states.push(s)
    }
  }
  NFA::{ states, }
}
