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

///|
test "codegen:play|pray" {
  let named_regexp : Array[(String, RegExp)] = [
    ("play", RegExp::String("play")),
    ("pray", RegExp::String("pray")),
  ]
  let generator = Generator::new(named_regexp)
  generator.add_dfa([1, 2] |> Set::from_array) |> ignore
  generator.save("./src/dfa/")
}
