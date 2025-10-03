///|
test "simple" {
  // 0 => S', 1 => S, 2 => A, 3 => B, 4 => EOF, 5 => a, 6 => b
  // S' -> S 
  // S -> A B
  // A -> a
  // B -> b
  let grammar = {
    rules: [
      [[1]], // S' -> S
      [[2, 3]], // S -> A B
      [[5]], // A -> a
      [[6]],
    ],
  } // B -> b
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
  // 0 => S', 1 => S, 2 => A, 3 => B, 4 => EOF, 5 => a, 6 => b, 7 => c
  // S' -> S 
  // S -> A B
  // A -> a
  // B -> b c b
  let grammar = {
    rules: [
      [[1]], // S' -> S
      [[2, 3]], // S -> A B
      [[5]], // A -> a
      [[6], [6, 7, 6]],
    ],
  } // B -> b | b c b
  let maker = LR1Maker::new(grammar)
  maker.construct_states()
  let lr1 = maker.to_lr1()
  let sem = {
    let names = [
      "%START",
      "S",
      "A",
      "B",
      @dfa.LAURUS_RESERVED_TOKEN_NAME,
      "a",
      "b",
      "c",
    ]
    let sorts = [
      { tag: AsType, type_name: "TyS" }, // %START
      { tag: StructType, type_name: "TyS" }, // S
      { tag: TupleType, type_name: "TyA" }, // A
      { tag: EnumType, type_name: "TyB" }, // B
    ]
    let rules = [
      [
        Reduction(
          parse_func_name="parseStart",
          parse_parameter_names=["s"],
          print_func_name="printStart",
        ),
      ],
      [Fields(["a", "b"])],
      [Tuple],
      [
        Constructor("One"),
        NamedConstructor("Two", field_names=["first", "second"]),
      ],
    ]
    let tokens = [
      TokenSemantics::BuiltIn("Lexeme"),
      Conversion(type_name="String", parse_func_name="", print_func_name=""),
      Conversion(
        type_name="String",
        parse_func_name="parseB",
        print_func_name="printB",
      ),
      TokenSemantics::Ignore,
    ]
    Semantics::new(names, sorts, rules, tokens)
  }
  let named_regexps : Array[(String, @dfa.RegExp)] = [
    ("a", @dfa.Single('a')),
    ("b", @dfa.Single('b')),
    ("c", @dfa.Single('c')),
  ]
  let generator = Generator::new(named_regexps)
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
