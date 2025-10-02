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
pub fn Parser::init(self : Self, src : String, cur? : Int = -1) -> Unit {
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
  TyS(TyS)
  TyA(TyA)
  TyB(TyB)
  Lexeme(Lexeme)
  String(String)
} derive(Show)

///|
pub fn Parser::parse(self : Self) -> TyS? {
  let mut lexeme = self.lexer.scan0()
  loop 0 {
    0 => {
      self.enter_state(0)
      // %START -> ● S | LAURUS
      // S -> ● A B | LAURUS
      // A -> ● a | b
      continue match lexeme.token {
          A => { // shift
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
      // %START -> S ● | LAURUS
      continue match lexeme.token {
          LAURUS => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::TyS(x0)
            let node = Interpreter::parseStart(x0) |> Node::TyS
            self.node_stack.push(node)
            break
          }
          _ => break
        }
    }
    2 => {
      self.enter_state(2)
      // S -> A ● B | LAURUS
      // B -> ● b | LAURUS
      // B -> ● b c b | LAURUS
      continue match lexeme.token {
          B => { // shift
            let node = self.lexer.get(lexeme)
              |> Interpreter::parseB
              |> Node::String
            self.node_stack.push(node)
            lexeme = self.lexer.scan2()
            5
          }
          _ => break
        }
    }
    3 => {
      self.enter_state(3)
      // A -> a ● | b
      continue match lexeme.token {
          B => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TyA(x0) |> Node::TyA
            self.node_stack.push(node)
            2
          }
          _ => break
        }
    }
    4 => {
      self.enter_state(4)
      // S -> A B ● | LAURUS
      continue match lexeme.token {
          LAURUS => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::TyB(x1)
            guard self.node_stack.unsafe_pop() is Node::TyA(x0)
            let node = TyS::{ a: x0, b: x1 } |> Node::TyS
            self.node_stack.push(node)
            1
          }
          _ => break
        }
    }
    5 => {
      self.enter_state(5)
      // B -> b ● | LAURUS
      // B -> b ● c b | LAURUS
      continue match lexeme.token {
          C => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan1()
            6
          }
          LAURUS => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = One(x0) |> Node::TyB
            self.node_stack.push(node)
            4
          }
          _ => break
        }
    }
    6 => {
      self.enter_state(6)
      // B -> b c ● b | LAURUS
      continue match lexeme.token {
          B => { // shift
            let node = self.lexer.get(lexeme)
              |> Interpreter::parseB
              |> Node::String
            self.node_stack.push(node)
            lexeme = self.lexer.scan3()
            7
          }
          _ => break
        }
    }
    7 => {
      self.enter_state(7)
      // B -> b c b ● | LAURUS
      continue match lexeme.token {
          LAURUS => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x2)
            //                             ignore Node::Unit(x1)
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = Two(first=x0, second=x2) |> Node::TyB
            self.node_stack.push(node)
            4
          }
          _ => break
        }
    }
    _ => break
  }
  match self.node_stack[0] {
    TyS(node) => Some(node)
    _ => None
  }
}
