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
test "a*" {
  let regexp_tokens : Array[(RegExp, Token)] = [(RegExp::Star(String("a")), 1)]
  let dfa = brzozowski(regexp_tokens)
  println("\{dfa}")
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
  let len = named_regexps.length()
  let names = Array::new(capacity=len + 2)
  let nfas = Array::new(capacity=len + 2)
  names.push(LAURUS_RESERVED_EOF)
  nfas.push(NFA::new([])) // we dont care
  names.push(LAURUS_RESERVED_SPACE)
  nfas.push(
    RegExp::Star(RegExp::Bor([(' ', ' '), ('\t', '\t'), ('\n', '\n')])).to_token_nfa(
      1,
    ),
  )
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
  generator.codegen_scan([2, 3]) |> ignore
  generator.save("./src/dfa/")
}
