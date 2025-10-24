///|
struct Parser {
  lexer : Lexer
  state_stack : Array[Int]
  node_stack : Array[Node]
} derive(Show)

///|
pub fn Parser::new(src? : String = "") -> Self {
  {
    lexer: Lexer::new(src~),
    state_stack: Array::new(),
    node_stack: Array::new(),
  }
}

///|
pub fn Parser::init(self : Self, src : String, cur? : Int = 0) -> Unit {
  self.lexer.init(src, cur~)
  self.state_stack.clear()
  self.node_stack.clear()
}

///|
#inline
fn Parser::enter_state(self : Self, state_i : Int) -> Unit {
  self.state_stack.push(state_i)
}

///|
enum Node {
  Unicode(Unicode)
  String(String)
} derive(Show)

///|
pub fn Parser::parse(self : Self) -> Unicode? {
  let mut lexeme = self.lexer.scan0()
  loop 0 {
    0 => {
      self.enter_state(0)
      continue match lexeme.token {
          NewMoon => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            lexeme = self.lexer.scan1()
            2
          }
          FullMoon => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            lexeme = self.lexer.scan1()
            3
          }
          _ => break
        }
    }
    1 => {
      self.enter_state(1)
      continue match lexeme.token {
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Unicode(x0)
            let node = x0 |> Node::Unicode
            self.node_stack.push(node)
            break
          }
          _ => break
        }
    }
    2 => {
      self.enter_state(2)
      continue match lexeme.token {
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = Unicode::NewMoon(x0) |> Node::Unicode
            self.node_stack.push(node)
            1
          }
          _ => break
        }
    }
    3 => {
      self.enter_state(3)
      continue match lexeme.token {
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = Unicode::FullMoon(x0) |> Node::Unicode
            self.node_stack.push(node)
            1
          }
          _ => break
        }
    }
    _ => break
  }
  match self.node_stack[0] {
    Unicode(node) => Some(node)
    _ => None
  }
}
