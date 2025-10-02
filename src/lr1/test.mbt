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
  let lr1 = maker.to_lr1()
  let names = [
    "%START",
    "S",
    "A",
    "B",
    @dfa.LAURUS_RESERVED_TOKEN_NAME,
    "a",
    "b",
  ]
  let named_regexps : Array[(String, @dfa.RegExp)] = [
    ("a", @dfa.Single('a')),
    ("b", @dfa.Single('b')),
  ]
  let generator = Generator::new(named_regexps)
  generator.codegen(lr1, names)
  generator.save("./src/lr1")
}
