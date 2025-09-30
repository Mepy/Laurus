///|
/// Conflict Resolution of LR1
/// 1. find the rule with maximum priority
/// 2. shift or reduce first for rules with the same priority
/// 
struct Resolution {
  // priority[sort][rule_i]
  priority : Array[Array[Int]]
  // shift_first[sort][rule_i]
  // coincide when different rules share the same priority
  shift_first : Array[Array[Bool]]
} derive(Show)

///|
/// See LR1Maker::resolution_generate, which generate Resolution with supergraph
struct RawResolution {
  // prior_than_former[sort][0] is redundant
  // 
  // prior_than_former[sort][rule_i + 1] = true 
  // IF AND ONLY IF
  // priority[sort][rule_i] < priority[sort][rule_i + 1]
  //
  prior_than_former : Array[Array[Bool]]
  shift_first : Array[Array[Bool]]
} derive(Show)

///|
/// 0 when Eq; (-) when lhs < rhs ; (+) when lhs > rhs
fn Resolution::compare(
  self : Self,
  lhs : (Sort, RuleIndex),
  rhs : (Sort, RuleIndex),
) -> Int {
  let (lhs_sort, lhs_rule_i) : (Sort, RuleIndex) = lhs
  let (rhs_sort, rhs_rule_i) : (Sort, RuleIndex) = rhs
  self.priority[lhs_sort][lhs_rule_i] - self.priority[rhs_sort][rhs_rule_i]
}

///|
/// generate Resolution with self.supergraph
fn LR1Maker::resolution_generate(
  self : Self,
  raw_res : RawResolution,
) -> Resolution {
  let priority = Array::makei(raw_res.prior_than_former.length(), i => Array::new(
    capacity=raw_res.prior_than_former[i].length(),
  ))
  let shift_first = raw_res.shift_first
  let mut cur_prior : Int = -1
  for scc_i in self.supergraph.topology {
    cur_prior += 1
    for sort in self.supergraph.sccs[scc_i].component {
      for ptf in raw_res.prior_than_former[sort] {
        if ptf { // prior than former
          cur_prior += 1
        }
        priority[sort].push(cur_prior)
      }
    }
  }
  Resolution::{ priority, shift_first }
}

///|
/// resolve reduce-reduce and shift-reduce conflicts
fn LR1Maker::resolve(self : Self, res : Resolution) -> Unit {
  fn max_sort_rule_i(sort_rules : Array[(Sort, RuleIndex)]) {
    sort_rules
    .iter()
    .take(1)
    .fold(init=sort_rules[0], (old_one, new_one) => {
      let cmp = res.compare(old_one, new_one)
      if cmp < 0 { // cmp (-) when old_one < new_one
        new_one
      } else {
        old_one
      }
    })
  }

  let len = self.reduce_table.length()
  for state_i in 0..<len {
    let reduce_table : Map[Token, Array[(Sort, RuleIndex)]] = self.reduce_table[state_i]
    let shift_table : Map[Token, (StateIndex, Array[(Sort, RuleIndex)])] = self.shift_table[state_i]
    for next_sort_rules in reduce_table {
      let (next, reduce_sort_rules) : (Token, Array[(Sort, RuleIndex)]) = next_sort_rules
      // resolve reduce-reduce conflict
      let reduce_sort_rule_i = max_sort_rule_i(reduce_sort_rules)
      guard shift_table.contains(next) else {
        // only reduce rules
        reduce_table[next] = [reduce_sort_rule_i]
      }

      // also shift rules
      // need to resolve shift-reduce conflicts
      let (_state_j, shift_sort_rules) : (StateIndex, Array[(Sort, RuleIndex)]) = shift_table[next]
      let shift_sort_rule_i = max_sort_rule_i(shift_sort_rules)
      let cmp = res.compare(shift_sort_rule_i, reduce_sort_rule_i)
      if cmp < 0 { // shift < reduce, should reduce, then remove shift
        shift_table.remove(next)
      } else if cmp > 0 { // shift > reduce, should shift, then remove reduce
        reduce_table.remove(next)
      } else { // priority shift = reduce, check shift_first?
        let (sort, rule_i) = shift_sort_rule_i
        if res.shift_first[sort][rule_i] {
          // shift first
          reduce_table.remove(next)
        } else {
          // reduce first
          shift_table.remove(next)
        }
      }
    }
  }
}
