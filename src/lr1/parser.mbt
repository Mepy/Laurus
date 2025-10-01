///|

///|
struct Parser {
  lexer : Lexer
  state_stack : Array[Int]
} derive(Show)

///|
pub fn Parser::new(src? : String = "") -> Self {
  { lexer: Lexer::new(src~), state_stack: Array::new() }
}

///|
pub fn Parser::init(self : Self, src : String, cur? : Int = -1) -> Unit {
  self.lexer.init(src, cur~)
  self.state_stack.clear()
}

///|
pub fn Parser::scan(self : Self) -> Unit {
  let mut lexeme = self.lexer.scan0()
  let goto_table = [{}, { 0: 1 }, { 0: 2 }, { 2: 4 }]
  loop 0 {
    0 =>
      continue match lexeme.token {
          A => { // shift
            lexeme = self.lexer.scan1()
            3
          }
          _ => break
        }
    1 =>
      continue match lexeme.token {
          LAURUS => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            break
          }
          _ => break
        }
    2 =>
      continue match lexeme.token {
          B => { // shift
            lexeme = self.lexer.scan2()
            5
          }
          _ => break
        }
    3 =>
      continue match lexeme.token {
          B => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            2
          }
          _ => break
        }
    4 =>
      continue match lexeme.token {
          LAURUS => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            1
          }
          _ => break
        }
    5 =>
      continue match lexeme.token {
          LAURUS => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            4
          }
          _ => break
        }
    _ => break
  }
}
