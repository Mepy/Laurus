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
  generator.codegen([1, 2])
  generator.save_file("./src/dfa/lexer.mbt")
}
