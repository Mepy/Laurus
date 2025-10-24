///|
test "unicode::simple" {
  let parser = Parser::new()
  parser.init("🌕")
  guard parser.parse() is Some(expr) else {  }
  assert_eq(expr.to_string(), "FullMoon(\"🌕\")")
  parser.init("🌑")
  guard parser.parse() is Some(expr) else {  }
  assert_eq(expr.to_string(), "NewMoon(\"🌑\")")
}
