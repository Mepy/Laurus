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
fn Generator::test_helper(named_regexps : Map[String, RegExp]) -> Generator {
  let len = named_regexps.size()
  let names = Array::new(capacity=len + 1)
  let nfas = Array::new(capacity=len + 1)
  names.push(LAURUS_RESERVED_TOKEN_NAME)
  nfas.push(NFA::new([])) // we dont care
  for name_regexp in named_regexps {
    let (name, regexp) = name_regexp
    nfas.push(regexp.to_token_nfa(names.length()))
    names.push(name)
  }
  Generator::new(names, nfas)
}

///|
test "codegen:play|pray" {
  let generator = Generator::test_helper({
    "Play": RegExp::String("play"),
    "Pray": RegExp::String("pray"),
  })
  generator.codegen([1, 2]) |> ignore
  generator.save("./src/dfa/")
}
