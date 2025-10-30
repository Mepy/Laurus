///|
pub struct Span {
  beg : Location
  end : Location
  children : FixedArray[Span]
} derive(Show)

///|
#inline
fn Span::leaf(beg : Location, end : Location) -> Span {
  { beg, end, children: FixedArray::default() }
}

///|
fn Span::tree(children : FixedArray[Span]) -> Span {
  let len = children.length()
  // guard len != 0
  let beg = children[0].beg
  let end = children[len - 1].end
  { beg, end, children }
}

///|
struct Parser {
  lexer : Lexer
  state_stack : Array[Int]
  span_stack : Array[Span]
  node_stack : Array[Node]
} derive(Show)

///|
pub fn Parser::new(src? : String = "") -> Self {
  {
    lexer: Lexer::new(src~),
    state_stack: Array::new(),
    span_stack: Array::new(),
    node_stack: Array::new(),
  }
}

///|
pub fn Parser::init(
  self : Self,
  src : String,
  cur? : Location = Location::default(),
) -> Unit {
  self.lexer.init(src, cur~)
  self.state_stack.clear()
  self.node_stack.clear()
}

///|
#inline
fn Parser::shift_span(self : Self, lexeme : Lexeme) -> Unit {
  // no need to clone lexeme.beg/end because it is to be consumed.
  self.span_stack.push(Span::leaf(lexeme.beg, lexeme.end))
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
pub fn Parser::parse(self : Self) -> Expr raise LexerError {
  let mut lexeme = self.lexer.scan0()
  loop 0 {
    0 => {
      self.enter_state(0)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan1()
            2
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
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
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            28
          }
          Sub => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            29
          }
          Mul => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            30
          }
          Div => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            31
          }
          Pow => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            32
          }
          LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = x0 |> Node::Expr
            self.node_stack.push(node)
            break
          }
          _ => break
        }
    }
    2 => {
      self.enter_state(2)
      continue match lexeme.token {
          LAURUS_EOF | Pow | Div | Mul | Sub | Add => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Int(x0)
            let node = Expr::Lit(x0) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 26
              10 => 25
              11 => 24
              12 => 23
              13 => 14
              15 => 22
              16 => 21
              17 => 20
              18 => 19
              28 => 45
              29 => 44
              30 => 43
              31 => 42
              32 => 33
              34 => 41
              35 => 40
              36 => 39
              37 => 38
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
            self.shift_span(lexeme)
            lexeme = self.lexer.scan2()
            5
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
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
            self.shift_span(lexeme)
            lexeme = self.lexer.scan1()
            27
          }
          Add => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            9
          }
          Sub => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            10
          }
          Mul => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            11
          }
          Div => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            12
          }
          Pow => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            13
          }
          _ => break
        }
    }
    5 => {
      self.enter_state(5)
      continue match lexeme.token {
          RParen | Pow | Div | Mul | Sub | Add => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Int(x0)
            let node = Expr::Lit(x0) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 26
              10 => 25
              11 => 24
              12 => 23
              13 => 14
              15 => 22
              16 => 21
              17 => 20
              18 => 19
              28 => 45
              29 => 44
              30 => 43
              31 => 42
              32 => 33
              34 => 41
              35 => 40
              36 => 39
              37 => 38
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
            self.shift_span(lexeme)
            lexeme = self.lexer.scan2()
            5
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
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
            self.shift_span(lexeme)
            lexeme = self.lexer.scan2()
            8
          }
          Add => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            9
          }
          Sub => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            10
          }
          Mul => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            11
          }
          Div => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            12
          }
          Pow => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            13
          }
          _ => break
        }
    }
    8 => {
      self.enter_state(8)
      continue match lexeme.token {
          RParen | Pow | Div | Mul | Sub | Add => { // reduce
            let span = self.span_stack[self.span_stack.length() - 3:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::Expr(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 26
              10 => 25
              11 => 24
              12 => 23
              13 => 14
              15 => 22
              16 => 21
              17 => 20
              18 => 19
              28 => 45
              29 => 44
              30 => 43
              31 => 42
              32 => 33
              34 => 41
              35 => 40
              36 => 39
              37 => 38
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
            self.shift_span(lexeme)
            lexeme = self.lexer.scan2()
            5
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
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
            self.shift_span(lexeme)
            lexeme = self.lexer.scan2()
            5
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
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
            self.shift_span(lexeme)
            lexeme = self.lexer.scan2()
            5
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
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
            self.shift_span(lexeme)
            lexeme = self.lexer.scan2()
            5
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
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
            self.shift_span(lexeme)
            lexeme = self.lexer.scan2()
            5
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
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
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            13
          }
          RParen | Div | Mul | Sub | Add => { // reduce
            let span = self.span_stack[self.span_stack.length() - 3:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Pow]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Pow(x0, x2) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 26
              10 => 25
              11 => 24
              12 => 23
              13 => 14
              15 => 22
              16 => 21
              17 => 20
              18 => 19
              28 => 45
              29 => 44
              30 => 43
              31 => 42
              32 => 33
              34 => 41
              35 => 40
              36 => 39
              37 => 38
              _ => break
            }
          }
          _ => break
        }
    }
    15 => {
      self.enter_state(15)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan2()
            5
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            6
          }
          _ => break
        }
    }
    16 => {
      self.enter_state(16)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan2()
            5
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            6
          }
          _ => break
        }
    }
    17 => {
      self.enter_state(17)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan2()
            5
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            6
          }
          _ => break
        }
    }
    18 => {
      self.enter_state(18)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan2()
            5
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            6
          }
          _ => break
        }
    }
    19 => {
      self.enter_state(19)
      continue match lexeme.token {
          Add => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            9
          }
          Mul => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            11
          }
          Div => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            12
          }
          Pow => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            13
          }
          Sub | RParen => { // reduce
            let span = self.span_stack[self.span_stack.length() - 3:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Add]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Add(x0, x2) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 26
              10 => 25
              11 => 24
              12 => 23
              13 => 14
              15 => 22
              16 => 21
              17 => 20
              18 => 19
              28 => 45
              29 => 44
              30 => 43
              31 => 42
              32 => 33
              34 => 41
              35 => 40
              36 => 39
              37 => 38
              _ => break
            }
          }
          _ => break
        }
    }
    20 => {
      self.enter_state(20)
      continue match lexeme.token {
          Div => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            12
          }
          Pow => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            13
          }
          Add | Mul | Sub | RParen => { // reduce
            let span = self.span_stack[self.span_stack.length() - 3:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Div]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Div(x0, x2) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 26
              10 => 25
              11 => 24
              12 => 23
              13 => 14
              15 => 22
              16 => 21
              17 => 20
              18 => 19
              28 => 45
              29 => 44
              30 => 43
              31 => 42
              32 => 33
              34 => 41
              35 => 40
              36 => 39
              37 => 38
              _ => break
            }
          }
          _ => break
        }
    }
    21 => {
      self.enter_state(21)
      continue match lexeme.token {
          Mul => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            11
          }
          Pow => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            13
          }
          Add | Div | Sub | RParen => { // reduce
            let span = self.span_stack[self.span_stack.length() - 3:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Mul]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Mul(x0, x2) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 26
              10 => 25
              11 => 24
              12 => 23
              13 => 14
              15 => 22
              16 => 21
              17 => 20
              18 => 19
              28 => 45
              29 => 44
              30 => 43
              31 => 42
              32 => 33
              34 => 41
              35 => 40
              36 => 39
              37 => 38
              _ => break
            }
          }
          _ => break
        }
    }
    22 => {
      self.enter_state(22)
      continue match lexeme.token {
          Sub => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            10
          }
          Mul => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            11
          }
          Div => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            12
          }
          Pow => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            13
          }
          Add | RParen => { // reduce
            let span = self.span_stack[self.span_stack.length() - 3:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Sub]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Sub(x0, x2) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 26
              10 => 25
              11 => 24
              12 => 23
              13 => 14
              15 => 22
              16 => 21
              17 => 20
              18 => 19
              28 => 45
              29 => 44
              30 => 43
              31 => 42
              32 => 33
              34 => 41
              35 => 40
              36 => 39
              37 => 38
              _ => break
            }
          }
          _ => break
        }
    }
    23 => {
      self.enter_state(23)
      continue match lexeme.token {
          Pow => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            13
          }
          RParen | Div | Mul | Sub | Add => { // reduce
            let span = self.span_stack[self.span_stack.length() - 3:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Div]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Div(x0, x2) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 26
              10 => 25
              11 => 24
              12 => 23
              13 => 14
              15 => 22
              16 => 21
              17 => 20
              18 => 19
              28 => 45
              29 => 44
              30 => 43
              31 => 42
              32 => 33
              34 => 41
              35 => 40
              36 => 39
              37 => 38
              _ => break
            }
          }
          _ => break
        }
    }
    24 => {
      self.enter_state(24)
      continue match lexeme.token {
          Pow => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            13
          }
          RParen | Div | Mul | Sub | Add => { // reduce
            let span = self.span_stack[self.span_stack.length() - 3:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Mul]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Mul(x0, x2) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 26
              10 => 25
              11 => 24
              12 => 23
              13 => 14
              15 => 22
              16 => 21
              17 => 20
              18 => 19
              28 => 45
              29 => 44
              30 => 43
              31 => 42
              32 => 33
              34 => 41
              35 => 40
              36 => 39
              37 => 38
              _ => break
            }
          }
          _ => break
        }
    }
    25 => {
      self.enter_state(25)
      continue match lexeme.token {
          Mul => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            11
          }
          Div => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            12
          }
          Pow => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            13
          }
          RParen | Sub | Add => { // reduce
            let span = self.span_stack[self.span_stack.length() - 3:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Sub]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Sub(x0, x2) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 26
              10 => 25
              11 => 24
              12 => 23
              13 => 14
              15 => 22
              16 => 21
              17 => 20
              18 => 19
              28 => 45
              29 => 44
              30 => 43
              31 => 42
              32 => 33
              34 => 41
              35 => 40
              36 => 39
              37 => 38
              _ => break
            }
          }
          _ => break
        }
    }
    26 => {
      self.enter_state(26)
      continue match lexeme.token {
          Mul => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            11
          }
          Div => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            12
          }
          Pow => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            13
          }
          RParen | Sub | Add => { // reduce
            let span = self.span_stack[self.span_stack.length() - 3:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Add]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Add(x0, x2) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 26
              10 => 25
              11 => 24
              12 => 23
              13 => 14
              15 => 22
              16 => 21
              17 => 20
              18 => 19
              28 => 45
              29 => 44
              30 => 43
              31 => 42
              32 => 33
              34 => 41
              35 => 40
              36 => 39
              37 => 38
              _ => break
            }
          }
          _ => break
        }
    }
    27 => {
      self.enter_state(27)
      continue match lexeme.token {
          LAURUS_EOF | Pow | Div | Mul | Sub | Add => { // reduce
            let span = self.span_stack[self.span_stack.length() - 3:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::Expr(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 26
              10 => 25
              11 => 24
              12 => 23
              13 => 14
              15 => 22
              16 => 21
              17 => 20
              18 => 19
              28 => 45
              29 => 44
              30 => 43
              31 => 42
              32 => 33
              34 => 41
              35 => 40
              36 => 39
              37 => 38
              _ => break
            }
          }
          _ => break
        }
    }
    28 => {
      self.enter_state(28)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan1()
            2
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            3
          }
          _ => break
        }
    }
    29 => {
      self.enter_state(29)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan1()
            2
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            3
          }
          _ => break
        }
    }
    30 => {
      self.enter_state(30)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan1()
            2
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            3
          }
          _ => break
        }
    }
    31 => {
      self.enter_state(31)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan1()
            2
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            3
          }
          _ => break
        }
    }
    32 => {
      self.enter_state(32)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan1()
            2
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            3
          }
          _ => break
        }
    }
    33 => {
      self.enter_state(33)
      continue match lexeme.token {
          Pow => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            32
          }
          LAURUS_EOF | Div | Mul | Sub | Add => { // reduce
            let span = self.span_stack[self.span_stack.length() - 3:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Pow]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Pow(x0, x2) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 26
              10 => 25
              11 => 24
              12 => 23
              13 => 14
              15 => 22
              16 => 21
              17 => 20
              18 => 19
              28 => 45
              29 => 44
              30 => 43
              31 => 42
              32 => 33
              34 => 41
              35 => 40
              36 => 39
              37 => 38
              _ => break
            }
          }
          _ => break
        }
    }
    34 => {
      self.enter_state(34)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan1()
            2
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            3
          }
          _ => break
        }
    }
    35 => {
      self.enter_state(35)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan1()
            2
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            3
          }
          _ => break
        }
    }
    36 => {
      self.enter_state(36)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan1()
            2
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            3
          }
          _ => break
        }
    }
    37 => {
      self.enter_state(37)
      continue match lexeme.token {
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan1()
            2
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            3
          }
          _ => break
        }
    }
    38 => {
      self.enter_state(38)
      continue match lexeme.token {
          Add => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            28
          }
          Mul => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            30
          }
          Div => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            31
          }
          Pow => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            32
          }
          Sub | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 3:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Add]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Add(x0, x2) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 26
              10 => 25
              11 => 24
              12 => 23
              13 => 14
              15 => 22
              16 => 21
              17 => 20
              18 => 19
              28 => 45
              29 => 44
              30 => 43
              31 => 42
              32 => 33
              34 => 41
              35 => 40
              36 => 39
              37 => 38
              _ => break
            }
          }
          _ => break
        }
    }
    39 => {
      self.enter_state(39)
      continue match lexeme.token {
          Div => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            31
          }
          Pow => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            32
          }
          Add | Mul | Sub | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 3:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Div]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Div(x0, x2) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 26
              10 => 25
              11 => 24
              12 => 23
              13 => 14
              15 => 22
              16 => 21
              17 => 20
              18 => 19
              28 => 45
              29 => 44
              30 => 43
              31 => 42
              32 => 33
              34 => 41
              35 => 40
              36 => 39
              37 => 38
              _ => break
            }
          }
          _ => break
        }
    }
    40 => {
      self.enter_state(40)
      continue match lexeme.token {
          Mul => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            30
          }
          Pow => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            32
          }
          Add | Div | Sub | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 3:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Mul]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Mul(x0, x2) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 26
              10 => 25
              11 => 24
              12 => 23
              13 => 14
              15 => 22
              16 => 21
              17 => 20
              18 => 19
              28 => 45
              29 => 44
              30 => 43
              31 => 42
              32 => 33
              34 => 41
              35 => 40
              36 => 39
              37 => 38
              _ => break
            }
          }
          _ => break
        }
    }
    41 => {
      self.enter_state(41)
      continue match lexeme.token {
          Sub => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            29
          }
          Mul => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            30
          }
          Div => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            31
          }
          Pow => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            32
          }
          Add | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 3:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Sub]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Sub(x0, x2) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 26
              10 => 25
              11 => 24
              12 => 23
              13 => 14
              15 => 22
              16 => 21
              17 => 20
              18 => 19
              28 => 45
              29 => 44
              30 => 43
              31 => 42
              32 => 33
              34 => 41
              35 => 40
              36 => 39
              37 => 38
              _ => break
            }
          }
          _ => break
        }
    }
    42 => {
      self.enter_state(42)
      continue match lexeme.token {
          Pow => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            32
          }
          LAURUS_EOF | Div | Mul | Sub | Add => { // reduce
            let span = self.span_stack[self.span_stack.length() - 3:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Div]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Div(x0, x2) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 26
              10 => 25
              11 => 24
              12 => 23
              13 => 14
              15 => 22
              16 => 21
              17 => 20
              18 => 19
              28 => 45
              29 => 44
              30 => 43
              31 => 42
              32 => 33
              34 => 41
              35 => 40
              36 => 39
              37 => 38
              _ => break
            }
          }
          _ => break
        }
    }
    43 => {
      self.enter_state(43)
      continue match lexeme.token {
          Pow => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            32
          }
          LAURUS_EOF | Div | Mul | Sub | Add => { // reduce
            let span = self.span_stack[self.span_stack.length() - 3:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Mul]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Mul(x0, x2) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 26
              10 => 25
              11 => 24
              12 => 23
              13 => 14
              15 => 22
              16 => 21
              17 => 20
              18 => 19
              28 => 45
              29 => 44
              30 => 43
              31 => 42
              32 => 33
              34 => 41
              35 => 40
              36 => 39
              37 => 38
              _ => break
            }
          }
          _ => break
        }
    }
    44 => {
      self.enter_state(44)
      continue match lexeme.token {
          Mul => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            30
          }
          Div => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            31
          }
          Pow => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            32
          }
          LAURUS_EOF | Sub | Add => { // reduce
            let span = self.span_stack[self.span_stack.length() - 3:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Sub]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Sub(x0, x2) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 26
              10 => 25
              11 => 24
              12 => 23
              13 => 14
              15 => 22
              16 => 21
              17 => 20
              18 => 19
              28 => 45
              29 => 44
              30 => 43
              31 => 42
              32 => 33
              34 => 41
              35 => 40
              36 => 39
              37 => 38
              _ => break
            }
          }
          _ => break
        }
    }
    45 => {
      self.enter_state(45)
      continue match lexeme.token {
          Mul => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            30
          }
          Div => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            31
          }
          Pow => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            32
          }
          LAURUS_EOF | Sub | Add => { // reduce
            let span = self.span_stack[self.span_stack.length() - 3:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Add]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Add(x0, x2) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              3 => 4
              6 => 7
              9 => 26
              10 => 25
              11 => 24
              12 => 23
              13 => 14
              15 => 22
              16 => 21
              17 => 20
              18 => 19
              28 => 45
              29 => 44
              30 => 43
              31 => 42
              32 => 33
              34 => 41
              35 => 40
              36 => 39
              37 => 38
              _ => break
            }
          }
          _ => break
        }
    }
    _ => break
  }
  guard self.node_stack[0] is Expr(node)
  node
}
