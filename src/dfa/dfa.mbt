///|
struct DState {
  token : Token?
  left : Array[CodePoint]
  right : Array[CodePoint]
  next : Array[Index] // 这里的 Index 是绝对值
} derive(Show)

///|
struct DFA {
  states : Array[DState]
} derive(Show)

///|
/// 将 DFA 转换为反向的 NFA
fn DFA::to_nfa_rev(self : DFA, token? : Token = 1) -> NFA {
  let dlen = self.states.length()
  let nlen = dlen + 1
  let nstates = Array::makei(nlen, _ => NState::new())
  let initial_nstate = nstates[0]
  let halting_nstate = nstates[dlen] // dlen = nlen - 1
  halting_nstate.token = Some(token) // 终止状态
  for i in 0..<dlen {
    let dstate = self.states[i]
    let ni = dlen - i
    // dfa 的状态 i 对应 nfa 的状态 dlen - i
    // dfa : 0 1 2 3 4
    // nfa : 5 4 3 2 1 0
    match dstate.token {
      // dfa 的终止状态, 应当是 nfa 的初始状态，由 initial_nstate 的 empty 指向
      Some(_) => initial_nstate.empty.add(ni) // ni 相对于 0 还是 ni
      None => ()
    }
    let maplen = dstate.next.length()
    for k in 0..<maplen {
      let l = dstate.left[k]
      let r = dstate.right[k]
      let j = dstate.next[k]
      // dstates[i] --[l, r]--> dstates[j]
      let nj = dlen - j
      // nstates[nj] --[l, r]--> nstates[ni]
      nstates[nj].insert(l, r, Set::from_array([ni - nj]))
    }
  }
  NFA::{ states: nstates }
}

///|
struct DFAMaker {
  states : Array[NState]
  cached_empty : Map[Subset, Subset]
  dfa_indices : Map[Subset, Index]
  dfa_nstates : Array[NState]
  worklist : Array[Subset]
  /// 记录冲突的 token ，用于报错，(token1, token2) 中 token1 < token2
  conflicts : Set[TokenSet]
}

///|
fn DFAMaker::from_nfa(nfa : NFA) -> DFAMaker {
  DFAMaker::{
    states: nfa.states,
    cached_empty: Map::new(),
    dfa_indices: Map::new(),
    dfa_nstates: Array::new(),
    worklist: Array::new(),
    conflicts: Set::new(),
  }
}

///|
/// empty closure
fn DFAMaker::empty(self : Self, s : Subset) -> Subset {
  match self.cached_empty.get(s) {
    Some(empty) => return empty
    None => ()
  }
  let mut empty : Set[Index] = Set::new()
  let stack = s.0.to_array()
  while stack.is_empty() == false {
    let i = stack.unsafe_pop()
    if empty.contains(i) == false {
      empty.add(i)
      match self.cached_empty.get(Subset(Set::from_array([i]))) {
        Some(new_empty) => empty = empty.union(new_empty.0)
        None =>
          for j in self.states[i].empty {
            let ji = j + i // j 是相对于 i 的偏移
            if empty.contains(ji) == false {
              stack.push(ji)
            }
          }
      }
    }
  }
  let empty = Subset(empty)
  self.cached_empty[s] = empty
  empty
}

///|
/// 添加子集
fn DFAMaker::add_subset(self : Self, s : Subset) -> Unit {
  if false == self.dfa_indices.contains(s) {
    self.worklist.push(s)
    let index = self.dfa_nstates.length()
    self.dfa_indices[s] = index
    self.dfa_nstates.push(NState::new())
  }
}

///|
fn DFAMaker::subset_construction(self : Self) -> Unit {
  let initial = self.empty(Subset(Set::from_array([0])))
  self.add_subset(initial)
  while false == self.worklist.is_empty() {
    let current = self.worklist.unsafe_pop()
    let dfa_nstate = self.dfa_nstates[self.dfa_indices[current]]
    let tokens = Set::new()
    for i in current.0 {
      let nstate = self.states[i]
      match nstate.token {
        Some(token) => tokens.add(token)
        None => ()
      }
      let maplen = nstate.next.length()
      for k in 0..<maplen {
        let l = nstate.left[k]
        let r = nstate.right[k]
        let next = nstate.next[k]
        // 这里要将相对于 i 的 next 转换为绝对的 next
        let next = next.to_array().iter().map(j => j + i) // j 是相对于 i 的偏移
        let next = Set::from_iter(next)
        dfa_nstate.insert(l, r, next)
      }
    }
    let token : Token? = match tokens.size() {
      0 => None
      1 => Some(tokens.to_array()[0])
      _ => {
        self.conflicts.add(TokenSet(tokens))
        let tokens = tokens.to_array()
        tokens.sort()
        Some(tokens[0]) // 选择最小的 token 作为代表
      }
    }
    dfa_nstate.token = token
    dfa_nstate.merge_range()
    let maplen = dfa_nstate.next.length()
    for k in 0..<maplen {
      let l = dfa_nstate.left[k]
      let r = dfa_nstate.right[k]
      let next = dfa_nstate.next[k]
      let next = self.empty(Subset(next))
      dfa_nstate.next[k] = next.0
      self.add_subset(next)
    }
  }
}

///|
fn DFAMaker::to_dfa(self : Self) -> DFA {
  self.subset_construction()
  let dstates = Array::new(capacity=self.dfa_nstates.length())
  for nstate in self.dfa_nstates {
    let left = nstate.left
    let right = nstate.right
    let next = nstate.next.map(subset => self.dfa_indices[subset])
    dstates.push(DState::{ token: nstate.token, left, right, next })
  }
  DFA::{ states: dstates }
}
