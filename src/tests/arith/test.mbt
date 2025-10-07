///|
test "arith::simple" {
  let parser = Parser::new()
  parser.init("1 + 2 * 3 - 4 ^ 2 ^ 2")
  guard parser.parse() is Some(expr) else {  }
  assert_eq(
    expr.to_string(),
    "Sub(Add(Lit(1), Mul(Lit(2), Lit(3))), Pow(Lit(4), Pow(Lit(2), Lit(2))))",
  )
}
