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
pub fn LR1Maker::shallow_resolve(
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
      guard act is Reduce else {
        // act is Shift, no shift-shift conflicts
        conflicts.remove(token)
        self.reduce_table[state_i].remove(token)
        continue
      }
      guard rules.length() == 1 else {
        // reduce-reduce conflicts remained
        conflicts[token] = rules.map(rule_i => ActRule::new(act, sort, rule_i))
        self.shift_table[state_i].remove(token)
        self.reduce_table[state_i][token] = rules.map(rule_i => (sort, rule_i))
      }

      // resolve
      conflicts.remove(token)
      self.shift_table[state_i].remove(token)
      self.reduce_table[state_i][token] = [(sort, rules[0])]
    }
    if conflicts.size() == 0 {
      conf.0.remove(state_i)
    }
  }
}

///|
pub fn LR1Maker::deep_resolve(
  self : Self,
  conf : Conflicts,
  res : Resolution,
) -> Unit {
  for state_conflicts in conf.0 {
    let (state_i, conflicts) : (StateIndex, Map[Token, Array[ActRule]]) = state_conflicts
    let sort_prevs : Map[Sort, Map[Sort, RuleIndex]] = Map::new() // find the maximal prev < item.cur
    for item in self.states[state_i] {
      guard item.cur < item.sentence.length() else { continue }
      let cur : Sort = item.sentence[item.cur]
      if self.is_token(cur) {
        continue
      }
      // assert sort is a Sort
      guard cur != item.sort else { continue }
      // we do not add circle
      sort_prevs.update(cur, prevs => match prevs {
        None => {
          let prevs = Map::new()
          prevs[item.sort] = item.rule_i
          Some(prevs)
        }
        Some(prevs) => {
          prevs.update(item.sort, rule_i => match rule_i {
            None => Some(item.rule_i)
            Some(rule_i) => {
              let prios = res.priority[item.sort]
              let new_rule_i = item.rule_i
              let prio = prios[rule_i]
              let new_prio = prios[new_rule_i]
              if prio < new_prio {
                Some(new_rule_i)
              } else if prio > new_prio {
                Some(rule_i)
              } else {
                Some(Int::max(rule_i, new_rule_i))
              }
            }
          })
          Some(prevs)
        }
      })
    }
    let rule_indices : Map[(Sort, RuleIndex), Index] = Map::new()
    fn add_rule(rule : (Sort, RuleIndex)) -> Index {
      match rule_indices.get(rule) {
        None => {
          let index = rule_indices.size()
          rule_indices[rule] = index
          index
        }
        Some(index) => index
      }
    }

    let edges : Set[(Index, Index)] = Set::new() // we will add rule_k <= prev < cur < rule_{k+1}  < ...
    fn add_edge(prev : (Sort, RuleIndex), next : (Sort, RuleIndex)) -> Unit {
      let prev_index = add_rule(prev)
      let next_index = add_rule(next)
      edges.add((prev_index, next_index))
    }

    for sort_prevs in sort_prevs {
      let (sort, prevs) : (Sort, Map[Sort, RuleIndex]) = sort_prevs
      for prev in prevs {
        for rule_j in 0..<res.priority[sort].length() {
          let cur = (sort, rule_j)
          let (prev_sort, prev_rule_i) = prev
          let prios = res.priority[prev_sort]
          let prio = prios[prev_rule_i]
          let prio_len = prios.length()
          let mut rule_k = 0
          while rule_k < prio_len && prios[rule_k] <= prio {
            add_edge((prev_sort, rule_k), cur)
            rule_k += 1
          }
          while rule_k < prio_len {
            add_edge(cur, (prev_sort, rule_k))
            rule_k += 1
          }
        }
      }
    }
    let n = rule_indices.size()
    let adj_matrix = FixedArray::makei(n, _ => FixedArray::make(n, false))
    for edge in edges {
      let (i, j) = edge
      adj_matrix[i][j] = true
    }
    // Floyd 
    for k in 0..<n {
      for i in 0..<n {
        for j in 0..<n {
          adj_matrix[i][j] = adj_matrix[i][j] ||
            (adj_matrix[i][k] && adj_matrix[k][j])
        }
      }
    }
    fn compare(actrule1 : ActRule, actrule2 : ActRule) -> Int {
      let rule1 = (actrule1.sort, actrule1.rule_i)
      let rule2 = (actrule2.sort, actrule2.rule_i)
      let i1 = rule_indices[rule1]
      let i2 = rule_indices[rule2]
      let le = adj_matrix[i1][i2]
      let ge = adj_matrix[i2][i1]
      match (le, ge) {
        (true, false) => -1
        (false, true) => 1
        (true, true) => 0
        (false, false) => 0
      }
    }

    for token_conflicts in conflicts {
      let (token, actrules) : (Token, Array[ActRule]) = token_conflicts
      // assert actrules.length() > 1 
      let mut max_actrule = actrules[0]
      let mut max_actrules = [max_actrule]
      for actrule in actrules.iter().drop(1) {
        match compare(max_actrule, actrule) {
          -1 => {
            max_actrule = actrule
            max_actrules = [actrule]
          }
          1 => ()
          _ => max_actrules.push(actrule)
        }
      }
      guard max_actrules.length() == 1 else {
        // if all shift
        if max_actrules.iter().all(actrule => actrule.act is Shift) {
          self.reduce_table[state_i].remove(token)
          conflicts.remove(token)
        } else {
          conflicts[token] = max_actrules
        }
      }
      conflicts.remove(token)
      match max_actrule.act {
        Shift => self.reduce_table[state_i].remove(token)
        Reduce => {
          self.shift_table[state_i].remove(token)
          self.reduce_table[state_i][token] = [
            (max_actrule.sort, max_actrule.rule_i),
          ]
        }
      }
    }
    if conflicts.size() == 0 {
      conf.0.remove(state_i)
    }
  }
}
