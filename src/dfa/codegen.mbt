///|
struct Generator {
  builder : StringBuilder
  mut dfa_count : Int
} derive(Show)

///|
fn Generator::new() -> Self {
  let builder = StringBuilder::new()
  let lexer =
    #|///|
    #|struct Lexeme {
    #|  mut token : Token
    #|  beg : Int
    #|  mut end : Int
    #|} derive(Show)
    #|
    #|///|
    #|fn Lexeme::new(beg? : Int = 0) -> Self {
    #|  { token: 0, beg, end: 0 }
    #|}
    #|
    #|///|
    #|struct Lexer {
    #|  mut src : String
    #|  mut cur : Int
    #|  mut lexeme : Lexeme
    #|} derive(Show)
    #|
    #|///|
    #|fn Lexer::new(src? : String = "") -> Self {
    #|  { src, cur: -1, lexeme: Lexeme::new() }
    #|}
    #|
    #|///|
    #|fn Lexer::init(self : Self, src : String, cur? : Int = -1) -> Unit {
    #|  self.src = src
    #|  self.cur = cur
    #|}
    #|
    #|///|
    #|fn Lexer::get(self : Self, lexeme : Lexeme) -> String {
    #|  let beg = lexeme.beg
    #|  let end = lexeme.end
    #|  self.src.unsafe_substring(start=beg, end=end + 1)
    #|}
    #|
    #|///|
    #|fn Lexer::next(self : Self) -> Int {
    #|  self.cur += 1 
    #|  if self.cur < self.src.length() {
    #|    self.src[self.cur]
    #|  } else {
    #|    -1
    #|  }
    #|}
    #|
    #|
  builder.write_string(lexer)
  { builder, dfa_count: 0 }
}

///|
fn Generator::codegen(self : Self, dfa : DFA) -> Unit {
  let scan_header =
    #|///|
    $|fn Lexer::scan\{self.dfa_count}(self : Self) -> Lexeme {
    #|  loop 0 {
    #|
  let scan_footer =
    #|    _ => break
    #|  }
    #|  let lexeme = self.lexeme
    #|  self.lexeme = Lexeme::new(beg=lexeme.end+1)
    #|  lexeme
    #|}
  self.builder.write_string(scan_header)
  let len = dfa.states.length()
  for i in 0..<len {
    let state = dfa.states[i]
    self.builder.write_string("    \{i} => {\n")
    match state.token {
      Some(token) => {
        self.builder.write_string("      self.lexeme.end = self.cur\n")
        self.builder.write_string("      self.lexeme.token = \{token}\n")
      }
      None => ()
    }
    let maplen = state.next.length()
    if maplen == 0 {
      self.builder.write_string("      break\n")
    } else {
      self.builder.write_string("      continue match self.next() {\n")
      for k in 0..<maplen {
        let l = state.left[k]
        let r = state.right[k]
        let next = state.next[k]
        fn convert(l) {
          match l {
            '\u{0}' => "'\\u{0}'"
            '\u{10FFFF}' => "'\\u{10FFFF}'"
            '\'' => "'\\''"
            '\\' => "'\\\\'"
            _ as c => "'\{c}'"
          }
        }

        if l == r {
          self.builder.write_string("          \{convert(l)} => \{next}\n")
        } else {
          self.builder.write_string(
            "          \{convert(l)}..=\{convert(r)} => \{next}\n",
          )
        }
      }
      self.builder.write_string("          _ => break\n")
      self.builder.write_string("        }\n")
    }
    self.builder.write_string("    }\n")
  }
  self.builder.write_string(scan_footer)
  self.dfa_count += 1
}

///|
test "codegen:play|pray" {
  let regexp_tokens : Array[(RegExp, Token)] = [
    (RegExp::String("play"), 1),
    (RegExp::String("pray"), 2),
  ]
  let dfa = brzozowski(regexp_tokens)
  let generator = Generator::new()
  generator.codegen(dfa)
  generator.builder.to_string() |> println
}
