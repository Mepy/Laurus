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
  loop 0 {
    0 => // state_0
      // %START -> ● S | LAURUS
      // S -> ● A B | LAURUS
      // A -> ● a | b
      continue match lexeme.token {
          A => { // shift
            lexeme = self.lexer.scan1()
            3
          }
          _ => break
        }
    1 => // state_1
      // %START -> S ● | LAURUS
      continue match lexeme.token {
          LAURUS => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            break
          }
          _ => break
        }
    2 => // state_2
      // S -> A ● B | LAURUS
      // B -> ● b | LAURUS
      continue match lexeme.token {
          B => { // shift
            lexeme = self.lexer.scan2()
            5
          }
          _ => break
        }
    3 => // state_3
      // A -> a ● | b
      continue match lexeme.token {
          B => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            2
          }
          _ => break
        }
    4 => // state_4
      // S -> A B ● | LAURUS
      continue match lexeme.token {
          LAURUS => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            1
          }
          _ => break
        }
    5 => // state_5
      // B -> b ● | LAURUS
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
