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
  // 0 => s', 1 => s, 2 => a, 3 => b, 4 => EOF, 5 => SPACE, 6 => A, 7 => B, 8 => C, 9 => D
  // s' -> s 
  // s -> a b
  // a -> A
  // b -> B | B C B
  let grammar = {
    rules: [
      [[1]], // s' -> s
      [[2, 3]], // s -> a b
      [[6]], // a -> A
      [[7], [7, 8, 7], [9, 3, 9]],
    ],
  } // b -> B | B C B | D b D
  let maker = LR1Maker::new(grammar)
  maker.construct_states()
  let lr1 = maker.to_lr1()
  let sem = {
    let names = [
      "%START",
      "s",
      "a",
      "b",
      @dfa.LAURUS_RESERVED_EOF,
      @dfa.LAURUS_RESERVED_SPACE,
      "A",
      "B",
      "C",
      "D",
    ]
    let rules : Array[Array[RuleSemantics]] = [
      [Interpret(parse_func_name="parseStart")],
      [Struct(["a", "b"])],
      [Tuple],
      [
        Constructor("One", [None]),
        Constructor("Two", [Some("first"), Some("second")]),
        Identity,
      ],
    ]
    let tokens : Array[TokenSemantics] = [
      Lexeme,
      Ignore,
      String,
      Interpret(type_name="String", parse_func_name="parseB"),
      Ignore,
      Ignore,
    ]
    let type_names : Array[String?] = [
      Some("TyS"),
      Some("TyS"),
      Some("TyA"),
      Some("TyB"),
    ]
    for token in 0..<tokens.length() {
      let type_name = match tokens[token] {
        Ignore => None
        Lexeme => Some("Lexeme")
        String => Some("String")
        Interpret(type_name~, ..) => Some(type_name)
      }
      type_names.push(type_name)
    }
    let tuple_types = { "TyA": TupleType::new(["String"]) }
    let struct_types = { "TyS": StructType::new([("a", "TyA"), ("b", "TyB")]) }
    let enum_types = {
      "TyB": EnumType::new({
        "One": EnumBranch::new([(None, "String")]),
        "Two": EnumBranch::new([
          (Some("first"), "String"),
          (Some("second"), "String"),
        ]),
      }),
    }
    let interpret_funcs : Map[InterpretFuncName, InterpretFuncType] = {}
    interpret_funcs[InterpretFuncName::new("String", "parseB")] = InterpretFuncType::new(
      "",
      [(Some("str"), "String")],
      "String",
    )
    interpret_funcs[InterpretFuncName::new("TyS", "parseStart")] = InterpretFuncType::new(
      "",
      [(None, "TyS")],
      "TyS",
    )
    Semantics::new(
      names, rules, tokens, type_names, type_names, type_names, tuple_types, struct_types,
      enum_types, interpret_funcs,
    )
  }
  let token_names = [
    @dfa.LAURUS_RESERVED_EOF,
    @dfa.LAURUS_RESERVED_SPACE,
    "A",
    "B",
    "C",
    "D",
  ]
  let token_nfas = [
    @dfa.Emp,
    @dfa.Star(@dfa.Bor([(' ', ' '), ('\t', '\t'), ('\n', '\n')])),
    @dfa.Single('a'),
    @dfa.Single('b'),
    @dfa.Single('c'),
    @dfa.Single('d'),
  ].mapi((i, regexp) => regexp.to_token_nfa(i))
  let lex_gen = @dfa.Generator::new(token_names, token_nfas)
  let generator = Generator::new(lex_gen)
  generator.codegen_lexer(lr1)
  generator.codegen_syntax_type(sem)
  generator.codegen_node_type(sem)
  generator.codegen_interpret(sem)
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
  parser.init("adbcbd")
  parser.parse() |> println
  let with_space =
    #| a 
    #|                   d
    #|  b 
    #|d
  parser.init(with_space)
  parser.parse() |> println
}
