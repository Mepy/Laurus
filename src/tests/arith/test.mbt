///|
test "arith::simple" {
  let parser = Parser::new()
  let src =
    $|1 + 2 
    $|*
    $|3 - 4 ^ 2 ^ 2
  parser.init(src)
  try {
    let expr = parser.parse()
    assert_eq(
      expr.to_string(),
      "Sub(Add(Lit(1), Mul(Lit(2), Lit(3))), Pow(Lit(4), Pow(Lit(2), Lit(2))))",
    )
  } catch {
    ExpectTokens(beg, end, tokens) =>
      println("At (\{beg}, \{end}), expect tokens : \{tokens}")
    e => raise e
  }
}
