///|
test "utlc::simple" {
  let parser = Parser::new()
  let src =
    $| \\ x -> ( x \\ x -> x )
    $|
  parser.init(src)
  try {
    let expr = parser.parse()
    println(expr)
  } catch {
    ExpectTokens(beg, end, tokens) =>
      println("At (\{beg}, \{end}), expect tokens : \{tokens}")
  }
}
