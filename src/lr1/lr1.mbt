///|
struct Grammar {
  rules : Array[Array[Sentence]] // rules[sort][rule_i]
} derive(Show)

///|
/// grammar[sort][rule_i] = sort -> sentence | lookahead,
/// cur points to the first symbol
struct Item {
  sort : Sort
  rule_i : RuleIndex
  sentence : Sentence
  cur : Index
  lookahead : Token
} derive(Show, Hash, Eq, Compare)

///|
struct ItemSet(Set[Item]) derive(Show, Eq)

///|
impl Hash for ItemSet with hash_combine(self : ItemSet, hasher : Hasher) {
  hasher.combine(self.hash())
}

///|
impl Hash for ItemSet with hash(self : ItemSet) -> Int {
  let s = self.0.to_array()
  s.sort()
  s.hash()
}

///|
struct State {
  items : ItemSet
} derive(Show, Hash, Eq)

///|
struct LR1Maker {
  grammar : Grammar
  sort_len : Symbol // sort < sort_len <= token
  empty : FixedArray[Bool]
  first : FixedArray[Set[Token]]
  worklist : Array[(State, StateIndex)] // state and its index
  state_indices : Map[State, StateIndex]

  // goto_table[state_i][sort] = state_j
  goto_table : Array[Map[Sort, StateIndex]]
  // shift_table[state_i][token] = (state_j, [(sort1, rule_i1), (sort2, rule_i2), ...])
  shift_table : Array[Map[Token, (StateIndex, Array[(Sort, RuleIndex)])]]
  // reduce_table[state_i][token] = [(sort1, rule_i1), (sort2, rule_i2), ...]
  reduce_table : Array[Map[Token, Array[(Sort, RuleIndex)]]]
} derive(Show)

///|
fn LR1Maker::new(grammar : Grammar) -> LR1Maker {
  let sort_len = grammar.rules.length()
  let empty = LR1Maker::initialize_empty(grammar, sort_len)
  let first = LR1Maker::initialize_first(grammar, sort_len, empty)
  let maker = LR1Maker::{
    grammar,
    sort_len,
    empty,
    first,
    worklist: Array::new(),
    state_indices: Map::new(),
    goto_table: Array::new(),
    shift_table: Array::new(),
    reduce_table: Array::new(),
  }
  maker
}

///|
fn LR1Maker::is_token(self : Self, sy : Symbol) -> Bool {
  self.sort_len <= sy
}

///|
fn LR1Maker::initialize_empty(
  grammar : Grammar,
  sort_len : Symbol,
) -> FixedArray[Bool] {
  let empty : FixedArray[Bool] = FixedArray::make(sort_len, false)
  let rules_for_empty : FixedArray[Array[Sentence]] = FixedArray::makei(
    sort_len,
    i => Array::new(capacity=grammar.rules[i].length()),
  )
  let mut not_fix = false
  for sort in 0..<sort_len {
    let rules : Array[Sentence] = grammar.rules[sort]
    let rules_for_empty : Array[Sentence] = rules_for_empty[sort] // store those containing only sorts
    for sentence in rules {
      if sentence.length() == 0 {
        empty[sort] = true // empty introduced
        not_fix = true // indicates that we need to update empty
      } else if empty[sort] == false { // only filling rules_for_empty when need to update
        if sentence.iter().all(symbol => symbol < sort_len) { // all sorts
          rules_for_empty.push(sentence)
        }
      }
    }
  }
  let workset : Set[Sort] = Set::new(capacity=sort_len)
  for sort in 0..<sort_len {
    if empty[sort] == false {
      workset.add(sort)
    }
  }
  while not_fix { // update empty
    not_fix = false
    for sort in workset {
      let rules : Array[Sentence] = rules_for_empty[sort]
      for sentence in rules {
        // sentence.length() > 0, asserted by above code
        // s -> s1 s2 s3 ... sn
        if sentence.iter().all(s => empty[s]) { // update empty[]
          empty[sort] = true
          workset.remove(sort)
          not_fix = true
          break // It's OK to skip following sentences of sort
        }
      }
    }
  }
  empty
}

///|
fn LR1Maker::initialize_first(
  grammar : Grammar,
  sort_len : Symbol,
  empty : FixedArray[Bool],
) -> FixedArray[Set[Token]] {
  let first : FixedArray[Set[Token]] = FixedArray::makei(sort_len, _ => Set::new())
  let adj_lists : Array[Array[Sort]] = Array::makei(sort_len, _ => Array::new()) // adj_lists[from] = [to0, to1, ...]
  for sort in 0..<sort_len {
    let rules : Array[Sentence] = grammar.rules[sort]
    for sentence in rules {
      for symbol in sentence {
        if sort_len <= symbol { // symbol is a Token
          first[sort].add(symbol)
          break // the following symbols will not appear in first!
        } else { // symbol is a Sort
          adj_lists[symbol].push(sort)
          if empty[symbol] == false {
            break // the following symbols will not appear in first!
          }
        }
      }
    }
  }

  // Process SCCs in topological order to propagate FIRST sets.
  // Within each SCC, all symbols have the same FIRST set due to mutual dependencies.
  // Then propagate FIRST sets from current SCC to dependent SCCs.
  let supergraph = SuperGraph::new(Graph::{ adj_lists, })
  let first_of_sccs = FixedArray::makei(supergraph.sccs.length(), _ => Set::new())
  for scc_i in supergraph.topology_sort() {
    for symbol in supergraph.sccs[scc_i].component { // union all first in the scc
      for f in first[symbol] {
        first_of_sccs[scc_i].add(f)
      }
      first[symbol] = first_of_sccs[scc_i]
    }
    for next_i in supergraph.scc_adj_lists[scc_i] { // scc adjacent
      for f in first_of_sccs[scc_i] {
        first_of_sccs[next_i].add(f)
      }
    }
  }
  first
}

///|
fn LR1Maker::first_of(self : Self, sentence : Iter[Symbol]) -> Set[Token] {
  let first = Set::new()
  for symbol in sentence {
    if self.is_token(symbol) { // symbol is a Token
      first.add(symbol)
      break
    } else { // symbol is a Sort
      for f in self.first[symbol] {
        first.add(f)
      }
      if self.empty[symbol] == false {
        break // no longer to search the next symbol
      }
    }
  }
  first
}

///|
/// internally mutate state, and return it for convenience
fn LR1Maker::enclosure(self : Self, state : State) -> State {
  let worklist = state.items.0.to_array()
  while worklist.length() > 0 {
    let item = worklist.unsafe_pop()
    // item = A -> done ● sort tail | lookahead
    let cur = item.cur
    let sentence = item.sentence
    guard cur < sentence.length()
    let sort = sentence[cur]
    guard false == self.is_token(sort)
    let tail = item.sentence.iter().drop(cur + 1)
    let new_lookaheads = tail.add(Iter::singleton(item.lookahead))
    let rules_of_sort = self.grammar.rules[sort]
    let len = rules_of_sort.length()
    for rule_i in 0..<len {
      for lookahead in new_lookaheads {
        let sentence : Sentence = rules_of_sort[rule_i]
        let new_item = Item::{ sort, rule_i, sentence, cur: cur + 1, lookahead }
        if true == state.items.0.add_and_check(new_item) { // newly added
          worklist.push(new_item)
        }
      }
    }
  }
  state
}

///|
fn LR1Maker::add_state(self : Self, new_state : State) -> StateIndex {
  let new_state = self.enclosure(new_state)
  let new_index = self.goto_table.length()
  let mut actual_index = new_index
  self.state_indices.update(new_state, index => match index {
    None => // newly added
      Some(new_index)
    Some(index) => {
      actual_index = index
      Some(index)
    }
  })
  if actual_index == new_index { // newly added
    self.worklist.push((new_state, new_index))
    self.goto_table.push(Map::new())
    self.shift_table.push(Map::new())
    let reduce_map = Map::new()
    for item in new_state.items.0 {
      guard item.cur == item.sentence.length()
      let lookahead = item.lookahead
      if false == reduce_map.contains(lookahead) {
        reduce_map[lookahead] = Array::new()
      }
      reduce_map[lookahead].push((item.sort, item.rule_i))
    }
    self.reduce_table.push(reduce_map)
  }
  actual_index
}

///|
fn LR1Maker::construct_states(self : Self) -> Unit {
  let initial_state = State::{
    items: ItemSet(
      Set::from_iter(
        Iter::singleton(Item::{
          sort: 0, // %START -> ● START | EOF
          rule_i: 0,
          sentence: [1],
          cur: 0,
          lookahead: TokenEOF,
        }),
      ),
    ),
  }
  let _ = self.add_state(initial_state)
  while self.worklist.length() > 0 {
    let (state, state_i) = self.worklist.unsafe_pop()
    let items = state.items.0
    // next_sort_rules[next] = [(sort, rule_i), ...] when next is a Token
    let next_sort_rules : Map[Symbol, Array[(Sort, RuleIndex)]] = Map::new()
    for item in items {
      let sentence : Sentence = item.sentence
      let cur = item.cur
      guard cur < sentence.length()
      let next = sentence[cur]
      if false == next_sort_rules.contains(next) {
        next_sort_rules[next] = []
      }
      if self.is_token(next) {
        next_sort_rules[next].push((item.sort, item.rule_i))
      }
    }
    let new_states : Map[Symbol, State] = Map::from_iter(
      next_sort_rules
      .keys()
      .map(next => (next, State::{ items: ItemSet(Set::new()) })),
    )
    for item in items {
      let sentence : Sentence = item.sentence
      let cur = item.cur
      guard cur < sentence.length()
      let next : Symbol = sentence[cur]
      new_states[next].items.0.add(Item::{ ..item, cur: cur + 1 })
    }
    for nn in new_states {
      let (next, new_state) = nn
      let state_j = self.add_state(new_state)
      if self.is_token(next) { // next is a Token
        self.shift_table[state_i][next] = (state_j, next_sort_rules[next])
      } else {
        self.goto_table[state_i][next] = state_j
      }
    }
  }
}
