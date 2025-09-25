///|
test "play|pray" {
  let regexp_tokens : Array[(RegExp, Token)] = [
    (RegExp::String("play"), 1),
    (RegExp::String("pray"), 2),
  ]
  let dfa = brzozowski(regexp_tokens)
  println(dfa)
}

///|
test "pa|pb" {
  let regexp_tokens : Array[(RegExp, Token)] = [
    (RegExp::Union([RegExp::String("pa"), RegExp::String("pb")]), 1),
  ]
  let dfa = brzozowski(regexp_tokens)
  println(dfa)
}
