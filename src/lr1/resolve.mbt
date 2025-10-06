///|
/// Conflict Resolution of LR1
/// 1. find the rule with maximum priority
/// 2. shift or reduce first for rules with the same priority
/// 
pub(all) struct Resolution {
  // priority[sort][rule_i] 
  // incomparable when having different sorts
  priority : Array[Array[Int]]
  // reduce_first[sort][rule_i]
  // coincide when different rules of the same sort share the same priority
  reduce_first : Array[Array[Bool]]
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
  reduce_first : Array[Array[Bool]]
} derive(Show)

///|
/// generate Resolution with self.supergraph
fn LR1Maker::resolution_generate(
  self : Self,
  raw_res : RawResolution,
) -> Resolution {
  let priority = Array::makei(raw_res.prior_than_former.length(), i => Array::new(
    capacity=raw_res.prior_than_former[i].length(),
  ))
  let reduce_first = raw_res.reduce_first
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
  Resolution::{ priority, reduce_first }
}

///|
enum Act {
  Shift
  Reduce
} derive(Show)

///|
pub(all) struct ActRule {
  act : Act
  sort : Sort
  rule_i : RuleIndex
} derive(Show)

///|
fn ActRule::new(act : Act, sort : Sort, rule_i : RuleIndex) -> Self {
  { act, sort, rule_i }
}

///|
pub(all) struct Conflicts(Map[StateIndex, Map[Token, Array[ActRule]]]) derive (
  Show,
)

///|
pub fn LR1Maker::conflicts(self : Self) -> Conflicts {
  //  LR1Maker {
  //  //shift_table[state_i][token] = (state_j, [(sort1, rule_i1), (sort2, rule_i2), ...])
  //    shift_table : Array[Map[Token, (StateIndex, Array[(Sort, RuleIndex)])]]
  //  //reduce_table[state_i][token] = [(sort1, rule_i1), (sort2, rule_i2), ...]
  //    reduce_table : Array[Map[Token, Array[(Sort, RuleIndex)]]]
  // }
  let state_len = self.reduce_table.length()
  let conflicts : Map[StateIndex, Map[Token, Array[ActRule]]] = Map::new()
  for state_i in 0..<state_len {
    let token_acts : Map[Token, Array[ActRule]] = Map::new()
    let shift_table = self.shift_table[state_i]
    let reduce_table = self.reduce_table[state_i]
    for token_reduce_rules in reduce_table {
      let (token, reduce_rules) = token_reduce_rules
      token_acts.update(token, acts => match acts {
        None => {
          let acts = reduce_rules.map(sort_rule_i => {
            let (sort, rule_i) = sort_rule_i
            ActRule::new(Reduce, sort, rule_i)
          })
          Some(acts)
        }
        Some(acts) => {
          for sort_rule_i in reduce_rules {
            let (sort, rule_i) = sort_rule_i
            acts.push(ActRule::new(Reduce, sort, rule_i))
          }
          Some(acts)
        }
      })
    }
    for token_shift_rules in shift_table {
      let (token, (_, shift_rules)) = token_shift_rules
      token_acts.update(token, acts => match acts {
        None => None // no reduce acts -> no shift-reduce conflicts!
        Some(acts) => {
          for sort_rule_i in shift_rules {
            let (sort, rule_i) = sort_rule_i
            acts.push(ActRule::new(Shift, sort, rule_i))
          }
          Some(acts)
        }
      })
    }
    // filter those acts.length() > 1
    let token_conflicts = token_acts
      .iter()
      .filter(token_acts => {
        let (_token, acts) = token_acts
        acts.length() > 1
      })
      |> Map::from_iter()
    if token_conflicts.size() != 0 {
      conflicts[state_i] = token_conflicts
    }
  }
  Conflicts(conflicts)
}

///|
/// simply resolve conflicts with resolution, this function will mutate the paramter (conf : Conflicts)
pub fn LR1Maker::simple_resolve(
  self : Self,
  conf : Conflicts,
  res : Resolution,
) -> Unit {
  for state_conflicts in conf.0 {
    let (state_i, conflicts) = state_conflicts
    for token_actrules in conflicts {
      let (token, actrules) = token_actrules
      let sort_act_rules : Map[Sort, (Priority, Act, Array[RuleIndex])] = Map::new()
      for actrule in actrules {
        let { act, sort, rule_i } = actrule
        sort_act_rules.update(sort, act_rule_i => match act_rule_i {
          None => Some((res.priority[sort][rule_i], act, [rule_i]))
          Some((old_prio, old_act, old_rules)) => {
            let prio = res.priority[sort][rule_i]
            if old_prio > prio {
              Some((old_prio, old_act, old_rules))
            } else if old_prio < prio {
              Some((prio, act, [rule_i]))
            } else { // old_prio == prio
              match (old_act, act, res.reduce_first[sort][rule_i]) {
                (Reduce, Shift, true) => Some((prio, old_act, old_rules))
                (Shift, Reduce, true) => Some((prio, act, [rule_i]))
                (Reduce, Shift, false) => Some((prio, act, [rule_i]))
                (Shift, Reduce, false) => Some((prio, old_act, old_rules))
                (Reduce, Reduce, _) => {
                  old_rules.push(rule_i)
                  Some((prio, Reduce, old_rules))
                }
                (Shift, Shift, _) => {
                  old_rules.push(rule_i)
                  Some((prio, Shift, old_rules))
                }
              }
            }
          }
        })
      }
      guard sort_act_rules.size() == 1 else {
        // different sorts
        let new_conflict = Array::new()
        let new_shift : Array[(Sort, RuleIndex)] = Array::new()
        let new_reduce : Array[(Sort, RuleIndex)] = Array::new()
        for sort_act_rule in sort_act_rules {
          let (sort, (_prio, act, rules)) = sort_act_rule
          match act {
            Shift =>
              for rule_i in rules {
                new_shift.push((sort, rule_i))
                new_conflict.push(ActRule::new(act, sort, rule_i))
              }
            Reduce =>
              for rule_i in rules {
                new_reduce.push((sort, rule_i))
                new_conflict.push(ActRule::new(act, sort, rule_i))
              }
          }
        }
        conflicts[token] = new_conflict
        self.shift_table[state_i][token] = (
          self.shift_table[state_i][token].0,
          new_shift,
        )
        self.reduce_table[state_i][token] = new_reduce
      }

      // resolve
      let (sort, (_prio, act, rules)) = sort_act_rules.iter().peek().unwrap()
      guard rules.length() == 1 else {
        // reduce-reduce conflicts remained
        conflicts[token] = rules.map(rule_i => ActRule::new(act, sort, rule_i))
        self.shift_table[state_i].remove(token)
        self.reduce_table[state_i][token] = rules.map(rule_i => (sort, rule_i))
      }

      // resolve
      conflicts.remove(token)
      match act {
        Shift => self.reduce_table[state_i].remove(token)
        Reduce => {
          self.shift_table[state_i].remove(token)
          self.reduce_table[state_i][token] = [(sort, rules[0])]
        }
      }
    }
    if conflicts.size() == 0 {
      conf.0.remove(state_i)
    }
  }
}
