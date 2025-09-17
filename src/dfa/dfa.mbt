///|
struct DState {
  token : Token?
  left : Array[CodePoint]
  right : Array[CodePoint]
  next : Array[Index]
}

///|
struct DFA {
  states : Array[NState]
}
