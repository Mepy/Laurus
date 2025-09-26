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
test "supremum/infimum" {
  let regexp = RegExp::Bor([('0', '0'), ('A', 'A'), ('a', 'a')])
  let regexp = RegExp::Union([
    regexp,
    RegExp::Seq([regexp, regexp]),
    RegExp::Seq([RegExp::String("1"), regexp]),
  ])
  let regexp_tokens : Array[(RegExp, Token)] = [(RegExp::Seq([regexp]), 1)]
  let dfa = brzozowski(regexp_tokens)
  let generator = Generator::new()
  generator.codegen(dfa)
  generator.builder.to_string() |> println
}

///|
/// token = 1
let esc : RegExp = RegExp::Single('\\')

///|
/// token = 2
let esc_no : RegExp = RegExp::Bnot([
  ('\\', '\\'),
  ('.', '.'),
  ('*', '*'),
  ('+', '+'),
  ('-', '-'),
  ('^', '^'),
  ('|', '|'),
  ('[', ']'),
  ('(', ')'),
])

///|
/// token = 3
let esc_origin : RegExp = RegExp::Bor([
  ('\\', '\\'),
  ('.', '.'),
  ('*', '*'),
  ('+', '+'),
  ('-', '-'),
  ('^', '^'),
  ('|', '|'),
  ('[', ']'),
  ('(', ')'),
])

///|
/// token = 4
let esc_space : RegExp = RegExp::Bor([('s', 's'), ('t', 't'), ('n', 'n')])

///|
let esc_unicode_prefix : RegExp = RegExp::Single('u')

///|
let hex : RegExp = RegExp::Bor([('0', '9'), ('a', 'f'), ('A', 'F')])

///|
let esc_unicode_codepoint : RegExp = RegExp::Union([
  hex,
  RegExp::Seq([hex, hex]),
  // RegExp::Seq([hex, hex, hex]),
  // RegExp::Seq([hex, hex, hex, hex]),
  // RegExp::Seq([hex, hex, hex, hex, hex]),
  RegExp::Seq([RegExp::String("10"), hex]), // hex, hex, hex
])

///|
/// token = 5
let esc_unicode : RegExp = RegExp::Seq([
  esc_unicode_prefix, esc_unicode_codepoint,
])

///|
/// token = 6
let dot : RegExp = RegExp::Single('.')

///|
/// token = 7
let star : RegExp = RegExp::Single('*')

///|
/// token = 8
let plus : RegExp = RegExp::Single('+')

///|
/// token = 9
let dash : RegExp = RegExp::Single('-')

///|
/// token = 10
let caret : RegExp = RegExp::Single('^')

///|
/// token = 11
let or : RegExp = RegExp::Single('|')

///|
/// token = 12
let left_parenthese : RegExp = RegExp::Single('(')

///|
/// token = 13
let right_parenthese : RegExp = RegExp::Single(')')

///|
/// token = 14
let left_bracket : RegExp = RegExp::Single('[')

///|
/// token = 15
let right_bracket : RegExp = RegExp::Single(']')

///|
let regexp_nfas : Map[String, NFA] = Map::from_array([
  ("esc", esc.to_token_nfa(1)),
  ("esc_no", esc_no.to_token_nfa(2)),
  ("esc_origin", esc_origin.to_token_nfa(3)),
  ("esc_space", esc_space.to_token_nfa(4)),
  ("esc_unicode", esc_unicode.to_token_nfa(5)),
  ("dot", dot.to_token_nfa(6)),
  ("star", star.to_token_nfa(7)),
  ("plus", plus.to_token_nfa(8)),
  ("dash", dash.to_token_nfa(9)),
  ("caret", caret.to_token_nfa(10)),
  ("or", or.to_token_nfa(11)),
  ("left_parenthese", left_parenthese.to_token_nfa(12)),
  ("right_parenthese", right_parenthese.to_token_nfa(13)),
  ("left_bracket", left_bracket.to_token_nfa(14)),
  ("right_bracket", right_bracket.to_token_nfa(15)),
])

///|
test "RegExp::Lexer" {
  let generator = Generator::new()
  {
    let nfas = [
      regexp_nfas["esc"],
      regexp_nfas["esc_no"],
      regexp_nfas["left_parenthese"],
      regexp_nfas["left_bracket"],
      regexp_nfas["dot"],
    ]
    let nfa = NFA::token_union(nfas.iter())
    let dfa = DFAMaker::from_nfa(nfa).to_dfa()
    generator.codegen(dfa)
  }
  {
    let nfas = [
      regexp_nfas["esc_origin"],
      regexp_nfas["esc_space"],
      regexp_nfas["esc_unicode"],
    ]
    let nfa = NFA::token_union(nfas.iter())
    let dfa = DFAMaker::from_nfa(nfa).to_dfa()
    generator.codegen(dfa)
  }
  {
    let nfas = [
      regexp_nfas["esc"],
      regexp_nfas["esc_no"],
      regexp_nfas["dot"],
      regexp_nfas["star"],
      regexp_nfas["plus"],
      regexp_nfas["or"],
      regexp_nfas["left_parenthese"],
      regexp_nfas["left_bracket"],
    ]
    let nfa = NFA::token_union(nfas.iter())
    let dfa = DFAMaker::from_nfa(nfa).to_dfa()
    generator.codegen(dfa)
  }
  @fs.write_string_to_file("./src/dfa/lexer.mbt", generator.builder.to_string())
}

///|
test "RegExp::arser" {
  let parser = Parser::new(src="我是什+")
  parser.parse() |> println
}
