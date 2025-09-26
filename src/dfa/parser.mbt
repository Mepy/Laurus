///|
enum SyntaxTree {
  Lexeme(Lexeme)
  String(StringBuilder)
  RegExp(RegExp)
} derive(Show)

///|
struct Parser {
  lexer : Lexer
  stack : Array[SyntaxTree]
  mut lexeme : Lexeme
} derive(Show)

///|
fn Parser::new(src? : String = "") -> Self {
  { lexer: Lexer::new(src~), stack: [], lexeme: Lexeme::new() }
}

///|
fn Parser::init(self : Self, src : String, cur? : Int = 0) -> Unit {
  self.lexer.init(src, cur~)
}

///|
fn Parser::parse(self : Self) -> RegExp? {
  loop 0 {
    0 => {
      let lexeme = self.lexer.scan0()
      println("\{lexeme} = \{self.lexer.get(lexeme)}")
      continue match lexeme.token {
          1 => // ESC
            1
          2 => { // ESC_NO
            let c : CodePoint = self.lexer.get(lexeme)[0].unsafe_to_char()
            let builder = StringBuilder::new()
            builder.write_char(c)
            self.stack.push(String(builder))
            2
          }
          7 => { // DOT
            self.stack.push(RegExp(RegExp::Any))
            break
          }
          _ => {
            println("\{lexeme}")
            break
          }
        }
    }
    1 => { // ESC lexeme 
      let lexeme = self.lexer.scan1()
      continue match lexeme.token {
          3 => { // ESC_ORIGIN
            let c : CodePoint = self.lexer.get(lexeme)[0].unsafe_to_char()
            let builder = StringBuilder::new()
            builder.write_char(c)
            self.stack.push(String(builder))
            2
          }
          4 => { // ESC_SPACE
            let c = self.lexer.get(lexeme)[0]
            let builder = StringBuilder::new()
            match c {
              's' => builder.write_char(' ')
              't' => builder.write_char('\t')
              'n' => builder.write_char('\n')
              _ => () // unreachable
            }
            self.stack.push(String(builder))
            2
          }
          5 => { // ESC_UNICODE
            let mut code = 0
            for c in self.lexer.get(lexeme).iter().drop(1) {
              let x = match c {
                '0' => 0
                '1' => 1
                '2' => 2
                '3' => 3
                '4' => 4
                '5' => 5
                '6' => 6
                '7' => 7
                '8' => 8
                '9' => 9
                'a' | 'A' => 10
                'b' | 'B' => 11
                'c' | 'C' => 12
                'd' | 'D' => 13
                'e' | 'E' => 14
                'f' | 'F' => 15
                _ => 0
              }
              code = code * 16 + x
            }
            let builder = StringBuilder::new()
            builder.write_char(code.unsafe_to_char())
            self.stack.push(String(builder))
            2
          }
          _ => break
        }
    }
    2 => { // String lexeme
      let lexeme = self.lexer.scan2()
      println("\{lexeme}")
      continue match lexeme.token {
          1 => { // ESC
            let lexeme = self.lexer.scan1()
            match lexeme.token {
              3 => { // ESC_ORIGIN
                let c : CodePoint = self.lexer.get(lexeme)[0].unsafe_to_char()
                match self.stack.last() {
                  Some(String(builder)) => builder.write_char(c)
                  _ => ()
                }
                2
              }
              4 => { // ESC_SPACE
                let c = self.lexer.get(lexeme)[0]
                match (self.stack.last(), c) {
                  (Some(String(builder)), 's') => builder.write_char(' ')
                  (Some(String(builder)), 't') => builder.write_char('\t')
                  (Some(String(builder)), 'n') => builder.write_char('\n')
                  _ => () // unreachable
                }
                2
              }
              5 => { // ESC_UNICODE
                let mut code = 0
                for c in self.lexer.get(lexeme).iter().drop(1) {
                  let x = match c {
                    '0' => 0
                    '1' => 1
                    '2' => 2
                    '3' => 3
                    '4' => 4
                    '5' => 5
                    '6' => 6
                    '7' => 7
                    '8' => 8
                    '9' => 9
                    'a' | 'A' => 10
                    'b' | 'B' => 11
                    'c' | 'C' => 12
                    'd' | 'D' => 13
                    'e' | 'E' => 14
                    'f' | 'F' => 15
                    _ => 0
                  }
                  code = code * 16 + x
                }
                match self.stack.last() {
                  Some(String(builder)) =>
                    builder.write_char(code.unsafe_to_char())
                  _ => ()
                }
                2
              }
              _ => break
            }
          }
          2 => { // ESC_NO
            println("\{lexeme} = \{self.lexer.get(lexeme)}")
            let c : CodePoint = self.lexer.get(lexeme)[0].unsafe_to_char()
            match self.stack.last() {
              Some(String(builder)) => builder.write_char(c)
              _ => ()
            }
            2
          }
          6 | 7 | 8 | 11 | 12 | 14 => { // DOT | STAR | PLUS | OR | LEFT_PARENTHESE | LEFT_BRACKET
            self.lexeme = lexeme
            match self.stack.unsafe_pop() {
              String(builder) =>
                self.stack.push(RegExp(RegExp::String(builder.to_string())))
              _ => ()
            }
            3
          }
          _ => break
        }
    }
    _ => break
  }
  println(self.stack)
  if self.stack.length() == 1 {
    match self.stack[0] {
      RegExp(regexp) => Some(regexp)
      _ => None
    }
  } else {
    None
  }
}
