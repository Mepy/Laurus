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
  Expr(Expr)
  Int(Int)
} derive(Show)
///|
pub fn Parser::parse(self : Self) -> Expr? {
  let mut lexeme = self.lexer.scan0()
  loop 0 {
    0 => {
      self.enter_state(0)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            lexeme = self.lexer.scan1()
            2
          }
          LParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            3
          }
          _ => break
        }
    }
    1 => {
      self.enter_state(1)
      continue match lexeme.token {
          Add => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            20
          }
          Sub => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            21
          }
          Mul => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            22
          }
          Div => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            23
          }
          Pow => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            24
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = (x0, ) |> Node::Expr
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
            guard self.node_stack.unsafe_pop() is Node::Int(x0)
            let node = Expr::Lit(x0, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Pow => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Int(x0)
            let node = Expr::Lit(x0, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Div => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Int(x0)
            let node = Expr::Lit(x0, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Mul => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Int(x0)
            let node = Expr::Lit(x0, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Sub => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Int(x0)
            let node = Expr::Lit(x0, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Add => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Int(x0)
            let node = Expr::Lit(x0, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          _ => break
        }
    }
    3 => {
      self.enter_state(3)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            lexeme = self.lexer.scan2()
            5
          }
          LParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            6
          }
          _ => break
        }
    }
    4 => {
      self.enter_state(4)
      continue match lexeme.token {
          RParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan1()
            19
          }
          Add => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            9
          }
          Sub => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            10
          }
          Mul => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            11
          }
          Div => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            12
          }
          Pow => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            13
          }
          _ => break
        }
    }
    5 => {
      self.enter_state(5)
      continue match lexeme.token {
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Int(x0)
            let node = Expr::Lit(x0, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Pow => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Int(x0)
            let node = Expr::Lit(x0, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Div => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Int(x0)
            let node = Expr::Lit(x0, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Mul => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Int(x0)
            let node = Expr::Lit(x0, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Sub => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Int(x0)
            let node = Expr::Lit(x0, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Add => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Int(x0)
            let node = Expr::Lit(x0, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          _ => break
        }
    }
    6 => {
      self.enter_state(6)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            lexeme = self.lexer.scan2()
            5
          }
          LParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            6
          }
          _ => break
        }
    }
    7 => {
      self.enter_state(7)
      continue match lexeme.token {
          RParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan2()
            8
          }
          Add => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            9
          }
          Sub => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            10
          }
          Mul => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            11
          }
          Div => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            12
          }
          Pow => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            13
          }
          _ => break
        }
    }
    8 => {
      self.enter_state(8)
      continue match lexeme.token {
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::Expr(x1)
            // ignore Node [x0 : LParen]
            let node = (x1, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Pow => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::Expr(x1)
            // ignore Node [x0 : LParen]
            let node = (x1, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Div => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::Expr(x1)
            // ignore Node [x0 : LParen]
            let node = (x1, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Mul => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::Expr(x1)
            // ignore Node [x0 : LParen]
            let node = (x1, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Sub => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::Expr(x1)
            // ignore Node [x0 : LParen]
            let node = (x1, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Add => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::Expr(x1)
            // ignore Node [x0 : LParen]
            let node = (x1, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          _ => break
        }
    }
    9 => {
      self.enter_state(9)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            lexeme = self.lexer.scan2()
            5
          }
          LParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            6
          }
          _ => break
        }
    }
    10 => {
      self.enter_state(10)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            lexeme = self.lexer.scan2()
            5
          }
          LParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            6
          }
          _ => break
        }
    }
    11 => {
      self.enter_state(11)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            lexeme = self.lexer.scan2()
            5
          }
          LParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            6
          }
          _ => break
        }
    }
    12 => {
      self.enter_state(12)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            lexeme = self.lexer.scan2()
            5
          }
          LParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            6
          }
          _ => break
        }
    }
    13 => {
      self.enter_state(13)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            lexeme = self.lexer.scan2()
            5
          }
          LParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            6
          }
          _ => break
        }
    }
    14 => {
      self.enter_state(14)
      continue match lexeme.token {
          Pow => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            13
          }
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Pow]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Pow(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Div => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Pow]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Pow(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Mul => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Pow]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Pow(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Sub => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Pow]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Pow(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Add => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Pow]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Pow(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          _ => break
        }
    }
    15 => {
      self.enter_state(15)
      continue match lexeme.token {
          Pow => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            13
          }
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Div]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Div(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Div => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Div]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Div(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Mul => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Div]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Div(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Sub => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Div]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Div(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Add => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Div]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Div(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          _ => break
        }
    }
    16 => {
      self.enter_state(16)
      continue match lexeme.token {
          Pow => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            13
          }
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Mul]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Mul(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Div => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Mul]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Mul(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Mul => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Mul]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Mul(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Sub => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Mul]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Mul(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Add => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Mul]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Mul(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          _ => break
        }
    }
    17 => {
      self.enter_state(17)
      continue match lexeme.token {
          Mul => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            11
          }
          Div => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            12
          }
          Pow => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            13
          }
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Sub]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Sub(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Sub => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Sub]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Sub(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Add => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Sub]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Sub(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          _ => break
        }
    }
    18 => {
      self.enter_state(18)
      continue match lexeme.token {
          Mul => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            11
          }
          Div => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            12
          }
          Pow => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            13
          }
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Add]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Add(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Sub => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Add]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Add(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Add => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Add]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Add(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          _ => break
        }
    }
    19 => {
      self.enter_state(19)
      continue match lexeme.token {
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::Expr(x1)
            // ignore Node [x0 : LParen]
            let node = (x1, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Pow => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::Expr(x1)
            // ignore Node [x0 : LParen]
            let node = (x1, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Div => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::Expr(x1)
            // ignore Node [x0 : LParen]
            let node = (x1, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Mul => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::Expr(x1)
            // ignore Node [x0 : LParen]
            let node = (x1, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Sub => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::Expr(x1)
            // ignore Node [x0 : LParen]
            let node = (x1, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Add => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::Expr(x1)
            // ignore Node [x0 : LParen]
            let node = (x1, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          _ => break
        }
    }
    20 => {
      self.enter_state(20)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            lexeme = self.lexer.scan1()
            2
          }
          LParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            3
          }
          _ => break
        }
    }
    21 => {
      self.enter_state(21)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            lexeme = self.lexer.scan1()
            2
          }
          LParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            3
          }
          _ => break
        }
    }
    22 => {
      self.enter_state(22)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            lexeme = self.lexer.scan1()
            2
          }
          LParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            3
          }
          _ => break
        }
    }
    23 => {
      self.enter_state(23)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            lexeme = self.lexer.scan1()
            2
          }
          LParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            3
          }
          _ => break
        }
    }
    24 => {
      self.enter_state(24)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            lexeme = self.lexer.scan1()
            2
          }
          LParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            3
          }
          _ => break
        }
    }
    25 => {
      self.enter_state(25)
      continue match lexeme.token {
          Pow => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            24
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Pow]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Pow(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Div => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Pow]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Pow(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Mul => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Pow]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Pow(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Sub => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Pow]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Pow(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Add => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Pow]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Pow(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          _ => break
        }
    }
    26 => {
      self.enter_state(26)
      continue match lexeme.token {
          Pow => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            24
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Div]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Div(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Div => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Div]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Div(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Mul => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Div]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Div(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Sub => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Div]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Div(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Add => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Div]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Div(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          _ => break
        }
    }
    27 => {
      self.enter_state(27)
      continue match lexeme.token {
          Pow => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            24
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Mul]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Mul(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Div => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Mul]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Mul(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Mul => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Mul]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Mul(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Sub => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Mul]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Mul(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Add => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Mul]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Mul(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          _ => break
        }
    }
    28 => {
      self.enter_state(28)
      continue match lexeme.token {
          Mul => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            22
          }
          Div => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            23
          }
          Pow => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            24
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Sub]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Sub(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Sub => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Sub]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Sub(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Add => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Sub]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Sub(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          _ => break
        }
    }
    29 => {
      self.enter_state(29)
      continue match lexeme.token {
          Mul => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            22
          }
          Div => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            23
          }
          Pow => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan0()
            24
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Add]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Add(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Sub => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Add]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Add(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          Add => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Add]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Add(x0, x2, ) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length()-1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 18
              10 => 17
              11 => 16
              12 => 15
              13 => 14
              20 => 29
              21 => 28
              22 => 27
              23 => 26
              24 => 25
              _ => break
            }
          }
          _ => break
        }
    }
    _ => break
  }
  match self.node_stack[0] {
    Expr(node) => Some(node)
    _ => None
  }
}
