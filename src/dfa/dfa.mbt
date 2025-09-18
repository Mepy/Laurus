///|
struct DState {
  token : Token?
  left : Array[CodePoint]
  right : Array[CodePoint]
  next : Array[Index] // 这里的 Index 是绝对值
}

///|
struct DFA {
  states : Array[NState]
}

///|
struct Subset(Set[Index]) derive(Eq)

///|
impl Hash for Subset with hash_combine(self : Subset, hasher : Hasher) {
  hasher.combine(self.hash())
}

///|
impl Hash for Subset with hash(self : Subset) -> Int {
  let s = self.0.to_array()
  s.sort()
  s.hash()
}

///|
struct DFAMaker {
  states : Array[NState]
  cached_empty : Map[Subset, Subset]
  dfa_indices : Map[Subset, Index]
  dfa_states : Array[NState]
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
            if empty.contains(j) == false {
              stack.push(j)
            }
          }
      }
    }
  }
  let empty = Subset(empty)
  self.cached_empty[s] = empty
  empty
}