///|
struct Grammar {
  rules : Array[Array[Sentence]] // rules[sort][rule_i]
} derive(Show)

///|
struct LR1Maker {
  grammar : Grammar
  sort_len : Symbol // sort < sort_len <= token
  empty : FixedArray[Bool]
  first : FixedArray[Set[Token]]
} derive(Show)

///|
fn LR1Maker::new(grammar : Grammar) -> LR1Maker {
  let sort_len = grammar.rules.length()
  let empty = LR1Maker::initialize_empty(grammar, sort_len)
  let first = LR1Maker::initialize_first(grammar, sort_len, empty)
  let maker = LR1Maker::{ grammar, sort_len, empty, first }
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
        let mut is_all_sort = true
        for symbol in sentence {
          if sort_len <= symbol { // symbol is a Token
            is_all_sort = false
            break
          }
        }
        if is_all_sort {
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
        let mut is_all_empty = true // s1 s2 s3 ... sn empty
        for si in sentence {
          if empty[si] == false {
            is_all_empty = false
            break
          }
        }
        if is_all_empty { // update empty[]
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
fn LR1Maker::first_of(self : Self, sentence : Array[Symbol]) -> Set[Token] {
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
