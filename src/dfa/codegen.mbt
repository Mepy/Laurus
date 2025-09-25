///|
fn DFA::codegen(self : Self) -> String {
  let builder = StringBuilder::new()
  let lexer =
    #|///|
    #|struct Lexer {
    #|  src : String
    #|  mut token : Token
    #|  mut cur : Int 
    #|  mut beg : Int 
    #|  mut end : Int
    #|} derive(Show)
    #|
    #|///|
    #|fn Lexer::new(src : String) -> Self {
    #|  Lexer::{ src, token: 0, cur: -1, beg: 0, end: 0 }
    #|}
    #|
    #|///|
    #|fn Lexer::next(self : Self) -> Int {
    #|  self.cur += 1 
    #|  if self.cur < self.src.length() {
    #|    self.src[self.cur]
    #|  } else {
    #|  -1
    #|  }
    #|}
    #|
    #|
  let scan_header =
    #|///|
    #|fn Lexer::scan(self : Self) -> (Token, Int, Int)? {
    #|  loop 0 {
  let scan_footer =
    #|    _ => break
    #|  }
    #|  if self.token == 0 {
    #|    None
    #|  } else {
    #|    let lexeme = Some((self.token, self.beg, self.end))
    #|    self.beg = self.end + 1
    #|    lexeme
    #|  }
    #|}
  builder.write_string(lexer)
  builder.write_string(scan_header)
  let accept_template =
    #|      self.end = self.cur
  let len = self.states.length()
  for i in 0..<len {
    let state = self.states[i]
    builder.write_string("    \{i} => {\n")
    match state.token {
      Some(token) => {
        builder.write_string(accept_template)
        builder.write_string("      self.token = \{token}\n")
      }
      None => ()
    }
    builder.write_string("      continue match self.next() {\n")
    let maplen = state.next.length()
    for k in 0..<maplen {
      let l = state.left[k]
      let r = state.right[k]
      let next = state.next[k]
      builder.write_string("          '\{l}'..='\{r}' => \{next}\n")
    }
    builder.write_string("          _ => break\n")
    builder.write_string("        }\n")
    builder.write_string("    }\n")
  }
  builder.write_string(scan_footer)
  builder.to_string()
}

///|
test "codegen:play|pray" {
  let regexp_tokens : Array[(RegExp, Token)] = [
    (RegExp::String("play"), 1),
    (RegExp::String("pray"), 2),
  ]
  let dfa = brzozowski(regexp_tokens)
  dfa.codegen() |> println
}
