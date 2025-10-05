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
      continue match lexeme.token {
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::TyS(x0)
            let node = TyS::parseStart(x0) |> Node::TyS
            self.node_stack.push(node)
            break
          }
          _ => break
        }
    }
    2 => {
      self.enter_state(2)
      continue match lexeme.token {
          B => { // shift
            let node = self.lexer.get(lexeme) |> String::parseB |> Node::String
            self.node_stack.push(node)
            lexeme = self.lexer.scan2()
            5
          }
          D => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan1()
            6
          }
          _ => break
        }
    }
    3 => {
      self.enter_state(3)
      continue match lexeme.token {
          B => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TyA(x0) |> Node::TyA
            self.node_stack.push(node)
            2
          }
          D => { // reduce
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
      continue match lexeme.token {
          LAURUS_EOF => { // reduce
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
      continue match lexeme.token {
          C => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan3()
            15
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TyB::One(x0) |> Node::TyB
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              2 => 4
              6 => 7
              9 => 10
              _ => break
            }
          }
          _ => break
        }
    }
    6 => {
      self.enter_state(6)
      continue match lexeme.token {
          B => { // shift
            let node = self.lexer.get(lexeme) |> String::parseB |> Node::String
            self.node_stack.push(node)
            lexeme = self.lexer.scan4()
            8
          }
          D => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan1()
            9
          }
          _ => break
        }
    }
    7 => {
      self.enter_state(7)
      continue match lexeme.token {
          D => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan5()
            14
          }
          _ => break
        }
    }
    8 => {
      self.enter_state(8)
      continue match lexeme.token {
          C => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan3()
            12
          }
          D => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TyB::One(x0) |> Node::TyB
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              2 => 4
              6 => 7
              9 => 10
              _ => break
            }
          }
          _ => break
        }
    }
    9 => {
      self.enter_state(9)
      continue match lexeme.token {
          B => { // shift
            let node = self.lexer.get(lexeme) |> String::parseB |> Node::String
            self.node_stack.push(node)
            lexeme = self.lexer.scan4()
            8
          }
          D => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan1()
            9
          }
          _ => break
        }
    }
    10 => {
      self.enter_state(10)
      continue match lexeme.token {
          D => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            11
          }
          _ => break
        }
    }
    11 => {
      self.enter_state(11)
      continue match lexeme.token {
          D => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : D]
            guard self.node_stack.unsafe_pop() is Node::TyB(x1)
            // ignore Node [x0 : D]
            let node = x1 |> Node::TyB
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              2 => 4
              6 => 7
              9 => 10
              _ => break
            }
          }
          _ => break
        }
    }
    12 => {
      self.enter_state(12)
      continue match lexeme.token {
          B => { // shift
            let node = self.lexer.get(lexeme) |> String::parseB |> Node::String
            self.node_stack.push(node)
            lexeme = self.lexer.scan6()
            13
          }
          _ => break
        }
    }
    13 => {
      self.enter_state(13)
      continue match lexeme.token {
          D => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x2)
            // ignore Node [x1 : C]
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TyB::Two(first=x0, second=x2) |> Node::TyB
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              2 => 4
              6 => 7
              9 => 10
              _ => break
            }
          }
          _ => break
        }
    }
    14 => {
      self.enter_state(14)
      continue match lexeme.token {
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : D]
            guard self.node_stack.unsafe_pop() is Node::TyB(x1)
            // ignore Node [x0 : D]
            let node = x1 |> Node::TyB
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              2 => 4
              6 => 7
              9 => 10
              _ => break
            }
          }
          _ => break
        }
    }
    15 => {
      self.enter_state(15)
      continue match lexeme.token {
          B => { // shift
            let node = self.lexer.get(lexeme) |> String::parseB |> Node::String
            self.node_stack.push(node)
            lexeme = self.lexer.scan5()
            16
          }
          _ => break
        }
    }
    16 => {
      self.enter_state(16)
      continue match lexeme.token {
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x2)
            // ignore Node [x1 : C]
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TyB::Two(first=x0, second=x2) |> Node::TyB
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              2 => 4
              6 => 7
              9 => 10
              _ => break
            }
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
