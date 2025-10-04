///|
test "simple" {
  // 0 => s', 1 => s, 2 => a, 3 => b, 4 => EOF, 5 => A, 6 => B
  // s' -> s 
  // s -> a b
  // a -> A
  // b -> B
  let grammar = {
    rules: [
      [[1]], // s' -> s
      [[2, 3]], // s -> a b
      [[5]], // a -> A
      [[6]],
    ],
  } // b -> B
  let maker = LR1Maker::new(grammar)
  maker.construct_states()
  println("states_len = \{maker.goto_table.length()}")
  println("\{maker.goto_table}")
  println("\{maker.shift_table}")
  println("\{maker.reduce_table}")
  println("\{maker.first_table}")
}

///|
test "codegen:simple" {
  // 0 => s', 1 => s, 2 => a, 3 => b, 4 => EOF, 5 => A, 6 => B, 7 => C
  // s' -> s 
  // s -> a b
  // a -> A
  // b -> B | B C B
  let grammar = {
    rules: [
      [[1]], // s' -> s
      [[2, 3]], // s -> a b
      [[5]], // a -> A
      [[6], [6, 7, 6]],
    ],
  } // b -> B | B C B
  let maker = LR1Maker::new(grammar)
  maker.construct_states()
  let lr1 = maker.to_lr1()
  let sem = {
    let names = [
      "%START",
      "s",
      "a",
      "b",
      @dfa.LAURUS_RESERVED_TOKEN_NAME,
      "A",
      "B",
      "C",
    ]
    let sorts = [
      { tag: AsType, type_name: "TyS" }, // %START
      { tag: StructType, type_name: "TyS" }, // s
      { tag: TupleType, type_name: "TyA" }, // A
      { tag: EnumType, type_name: "TyB" }, // B
    ]
    let rules = [
      [Reduction(parse_func_name="parseStart", parse_parameter_names=["s"])],
      [Fields(["a", "b"])],
      [Tuple],
      [
        Constructor("One"),
        NamedConstructor("Two", field_names=["first", "second"]),
      ],
    ]
    let tokens = [
      TokenSemantics::BuiltIn("Lexeme"),
      Conversion(type_name="String", parse_func_name=""),
      Conversion(type_name="String", parse_func_name="parseB"),
      TokenSemantics::Ignore,
    ]
    Semantics::new(names, sorts, rules, tokens)
  }
  let token_names = [@dfa.LAURUS_RESERVED_TOKEN_NAME, "A", "B", "C"]
  let token_nfas = [
    @dfa.Emp,
    @dfa.Single('a'),
    @dfa.Single('b'),
    @dfa.Single('c'),
  ].mapi((i, regexp) => regexp.to_token_nfa(i))
  let lex_gen = @dfa.Generator::new(token_names, token_nfas)
  let generator = Generator::new(lex_gen)
  generator.codegen_lexer(lr1)
  generator.codegen_sort_type(lr1, sem)
  generator.codegen_node_type(sem)
  generator.codegen_interpreter(lr1, sem)
  generator.codegen_parse(lr1, sem)
  generator.save("./src/lr1")
}

///|
test "parse:simple" {
  let parser = Parser::new()
  parser.init("abcb")
  parser.parse() |> println
  parser.init("ab")
  parser.parse() |> println
}
