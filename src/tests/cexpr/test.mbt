///|
test "arith::simple" {
  let parser = Parser::new()
  let src =
    $|  p
    $|? 
    $|  p = 1 
    $|: 
    $|  p = 1
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
