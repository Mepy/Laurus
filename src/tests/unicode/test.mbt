///|
test "unicode::simple" {
  let parser = Parser::new()
  parser.init("🌕")
  let expr = parser.parse()
  assert_eq(expr.to_string(), "FullMoon(\"🌕\")")
  parser.init("🌑")
  let expr = parser.parse()
  assert_eq(expr.to_string(), "NewMoon(\"🌑\")")
}
