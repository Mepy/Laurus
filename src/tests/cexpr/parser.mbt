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
  String(String)
  Int(Int)
} derive(Show)

///|
pub fn Parser::parse(self : Self) -> Expr raise LexerError {
  let mut lexeme = self.lexer.scan0()
  loop 0 {
    0 => {
      self.enter_state(0)
      // %start -> ● expr | LAURUS_EOF
      // expr -> ● Var Assign expr | LAURUS_EOF
      // expr -> ● expr Ques expr Colon expr | LAURUS_EOF
      // expr -> ● Lit | LAURUS_EOF
      // expr -> ● Var | LAURUS_EOF
      // expr -> ● LParen expr RParen | LAURUS_EOF
      // expr -> ● Var Assign expr | Ques
      // expr -> ● expr Ques expr Colon expr | Ques
      // expr -> ● Lit | Ques
      // expr -> ● Var | Ques
      // expr -> ● LParen expr RParen | Ques
      continue match lexeme.token {
          Var => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan2()
            2
          }
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan1()
            3
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            4
          }
          _ => break
        }
    }
    1 => {
      self.enter_state(1)
      // %start -> expr ● | LAURUS_EOF
      // expr -> expr ● Ques expr Colon expr | LAURUS_EOF
      // expr -> expr ● Ques expr Colon expr | Ques
      continue match lexeme.token {
          Ques => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            31
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
      // expr -> Var ● Assign expr | LAURUS_EOF
      // expr -> Var ● | LAURUS_EOF
      // expr -> Var ● Assign expr | Ques
      // expr -> Var ● | Ques
      continue match lexeme.token {
          Assign => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            29
          }
          LAURUS_EOF | Ques => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = Expr::Var(x0) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              4 => 5
              8 => 9
              11 => 12
              15 => 16
              18 => 19
              20 => 21
              22 => 23
              24 => 25
              26 => 27
              29 => 30
              31 => 32
              33 => 34
              _ => break
            }
          }
          _ => break
        }
    }
    3 => {
      self.enter_state(3)
      // expr -> Lit ● | LAURUS_EOF
      // expr -> Lit ● | Ques
      continue match lexeme.token {
          LAURUS_EOF | Ques => { // reduce
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
              4 => 5
              8 => 9
              11 => 12
              15 => 16
              18 => 19
              20 => 21
              22 => 23
              24 => 25
              26 => 27
              29 => 30
              31 => 32
              33 => 34
              _ => break
            }
          }
          _ => break
        }
    }
    4 => {
      self.enter_state(4)
      // expr -> LParen ● expr RParen | LAURUS_EOF
      // expr -> LParen ● expr RParen | Ques
      // expr -> ● Var Assign expr | RParen
      // expr -> ● expr Ques expr Colon expr | RParen
      // expr -> ● Lit | RParen
      // expr -> ● Var | RParen
      // expr -> ● LParen expr RParen | RParen
      // expr -> ● Var Assign expr | Ques
      // expr -> ● expr Ques expr Colon expr | Ques
      // expr -> ● Lit | Ques
      // expr -> ● Var | Ques
      // expr -> ● LParen expr RParen | Ques
      continue match lexeme.token {
          Var => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan4()
            6
          }
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            7
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            8
          }
          _ => break
        }
    }
    5 => {
      self.enter_state(5)
      // expr -> LParen expr ● RParen | LAURUS_EOF
      // expr -> LParen expr ● RParen | Ques
      // expr -> expr ● Ques expr Colon expr | RParen
      // expr -> expr ● Ques expr Colon expr | Ques
      continue match lexeme.token {
          RParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan1()
            28
          }
          Ques => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            11
          }
          _ => break
        }
    }
    6 => {
      self.enter_state(6)
      // expr -> Var ● Assign expr | RParen
      // expr -> Var ● | RParen
      // expr -> Var ● Assign expr | Ques
      // expr -> Var ● | Ques
      continue match lexeme.token {
          Assign => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            26
          }
          RParen | Ques => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = Expr::Var(x0) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              4 => 5
              8 => 9
              11 => 12
              15 => 16
              18 => 19
              20 => 21
              22 => 23
              24 => 25
              26 => 27
              29 => 30
              31 => 32
              33 => 34
              _ => break
            }
          }
          _ => break
        }
    }
    7 => {
      self.enter_state(7)
      // expr -> Lit ● | RParen
      // expr -> Lit ● | Ques
      continue match lexeme.token {
          RParen | Ques => { // reduce
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
              4 => 5
              8 => 9
              11 => 12
              15 => 16
              18 => 19
              20 => 21
              22 => 23
              24 => 25
              26 => 27
              29 => 30
              31 => 32
              33 => 34
              _ => break
            }
          }
          _ => break
        }
    }
    8 => {
      self.enter_state(8)
      // expr -> LParen ● expr RParen | RParen
      // expr -> LParen ● expr RParen | Ques
      // expr -> ● Var Assign expr | RParen
      // expr -> ● expr Ques expr Colon expr | RParen
      // expr -> ● Lit | RParen
      // expr -> ● Var | RParen
      // expr -> ● LParen expr RParen | RParen
      // expr -> ● Var Assign expr | Ques
      // expr -> ● expr Ques expr Colon expr | Ques
      // expr -> ● Lit | Ques
      // expr -> ● Var | Ques
      // expr -> ● LParen expr RParen | Ques
      continue match lexeme.token {
          Var => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan4()
            6
          }
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            7
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            8
          }
          _ => break
        }
    }
    9 => {
      self.enter_state(9)
      // expr -> LParen expr ● RParen | RParen
      // expr -> LParen expr ● RParen | Ques
      // expr -> expr ● Ques expr Colon expr | RParen
      // expr -> expr ● Ques expr Colon expr | Ques
      continue match lexeme.token {
          RParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            10
          }
          Ques => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            11
          }
          _ => break
        }
    }
    10 => {
      self.enter_state(10)
      // expr -> LParen expr RParen ● | RParen
      // expr -> LParen expr RParen ● | Ques
      continue match lexeme.token {
          RParen | Ques => { // reduce
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
              4 => 5
              8 => 9
              11 => 12
              15 => 16
              18 => 19
              20 => 21
              22 => 23
              24 => 25
              26 => 27
              29 => 30
              31 => 32
              33 => 34
              _ => break
            }
          }
          _ => break
        }
    }
    11 => {
      self.enter_state(11)
      // expr -> expr Ques ● expr Colon expr | RParen
      // expr -> expr Ques ● expr Colon expr | Ques
      // expr -> ● Var Assign expr | Colon
      // expr -> ● expr Ques expr Colon expr | Colon
      // expr -> ● Lit | Colon
      // expr -> ● Var | Colon
      // expr -> ● LParen expr RParen | Colon
      // expr -> ● Var Assign expr | Ques
      // expr -> ● expr Ques expr Colon expr | Ques
      // expr -> ● Lit | Ques
      // expr -> ● Var | Ques
      // expr -> ● LParen expr RParen | Ques
      continue match lexeme.token {
          Var => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            13
          }
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan5()
            14
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            15
          }
          _ => break
        }
    }
    12 => {
      self.enter_state(12)
      // expr -> expr Ques expr ● Colon expr | RParen
      // expr -> expr Ques expr ● Colon expr | Ques
      // expr -> expr ● Ques expr Colon expr | Colon
      // expr -> expr ● Ques expr Colon expr | Ques
      continue match lexeme.token {
          Colon => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            24
          }
          Ques => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            20
          }
          _ => break
        }
    }
    13 => {
      self.enter_state(13)
      // expr -> Var ● Assign expr | Colon
      // expr -> Var ● | Colon
      // expr -> Var ● Assign expr | Ques
      // expr -> Var ● | Ques
      continue match lexeme.token {
          Assign => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            18
          }
          Colon | Ques => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = Expr::Var(x0) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              4 => 5
              8 => 9
              11 => 12
              15 => 16
              18 => 19
              20 => 21
              22 => 23
              24 => 25
              26 => 27
              29 => 30
              31 => 32
              33 => 34
              _ => break
            }
          }
          _ => break
        }
    }
    14 => {
      self.enter_state(14)
      // expr -> Lit ● | Colon
      // expr -> Lit ● | Ques
      continue match lexeme.token {
          Colon | Ques => { // reduce
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
              4 => 5
              8 => 9
              11 => 12
              15 => 16
              18 => 19
              20 => 21
              22 => 23
              24 => 25
              26 => 27
              29 => 30
              31 => 32
              33 => 34
              _ => break
            }
          }
          _ => break
        }
    }
    15 => {
      self.enter_state(15)
      // expr -> LParen ● expr RParen | Colon
      // expr -> LParen ● expr RParen | Ques
      // expr -> ● Var Assign expr | RParen
      // expr -> ● expr Ques expr Colon expr | RParen
      // expr -> ● Lit | RParen
      // expr -> ● Var | RParen
      // expr -> ● LParen expr RParen | RParen
      // expr -> ● Var Assign expr | Ques
      // expr -> ● expr Ques expr Colon expr | Ques
      // expr -> ● Lit | Ques
      // expr -> ● Var | Ques
      // expr -> ● LParen expr RParen | Ques
      continue match lexeme.token {
          Var => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan4()
            6
          }
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            7
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            8
          }
          _ => break
        }
    }
    16 => {
      self.enter_state(16)
      // expr -> LParen expr ● RParen | Colon
      // expr -> LParen expr ● RParen | Ques
      // expr -> expr ● Ques expr Colon expr | RParen
      // expr -> expr ● Ques expr Colon expr | Ques
      continue match lexeme.token {
          RParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan5()
            17
          }
          Ques => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            11
          }
          _ => break
        }
    }
    17 => {
      self.enter_state(17)
      // expr -> LParen expr RParen ● | Colon
      // expr -> LParen expr RParen ● | Ques
      continue match lexeme.token {
          Colon | Ques => { // reduce
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
              4 => 5
              8 => 9
              11 => 12
              15 => 16
              18 => 19
              20 => 21
              22 => 23
              24 => 25
              26 => 27
              29 => 30
              31 => 32
              33 => 34
              _ => break
            }
          }
          _ => break
        }
    }
    18 => {
      self.enter_state(18)
      // expr -> Var Assign ● expr | Colon
      // expr -> Var Assign ● expr | Ques
      // expr -> ● Var Assign expr | Ques
      // expr -> ● expr Ques expr Colon expr | Ques
      // expr -> ● Lit | Ques
      // expr -> ● Var | Ques
      // expr -> ● LParen expr RParen | Ques
      // expr -> ● Var Assign expr | Colon
      // expr -> ● expr Ques expr Colon expr | Colon
      // expr -> ● Lit | Colon
      // expr -> ● Var | Colon
      // expr -> ● LParen expr RParen | Colon
      continue match lexeme.token {
          Var => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            13
          }
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan5()
            14
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            15
          }
          _ => break
        }
    }
    19 => {
      self.enter_state(19)
      // expr -> Var Assign expr ● | Colon
      // expr -> Var Assign expr ● | Ques
      // expr -> expr ● Ques expr Colon expr | Ques
      // expr -> expr ● Ques expr Colon expr | Colon
      continue match lexeme.token {
          Ques => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            20
          }
          Colon => { // reduce
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
            // ignore Node [x1 : Assign]
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = Expr::Assign(x0, x2) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              4 => 5
              8 => 9
              11 => 12
              15 => 16
              18 => 19
              20 => 21
              22 => 23
              24 => 25
              26 => 27
              29 => 30
              31 => 32
              33 => 34
              _ => break
            }
          }
          _ => break
        }
    }
    20 => {
      self.enter_state(20)
      // expr -> expr Ques ● expr Colon expr | Ques
      // expr -> expr Ques ● expr Colon expr | Colon
      // expr -> ● Var Assign expr | Colon
      // expr -> ● expr Ques expr Colon expr | Colon
      // expr -> ● Lit | Colon
      // expr -> ● Var | Colon
      // expr -> ● LParen expr RParen | Colon
      // expr -> ● Var Assign expr | Ques
      // expr -> ● expr Ques expr Colon expr | Ques
      // expr -> ● Lit | Ques
      // expr -> ● Var | Ques
      // expr -> ● LParen expr RParen | Ques
      continue match lexeme.token {
          Var => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            13
          }
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan5()
            14
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            15
          }
          _ => break
        }
    }
    21 => {
      self.enter_state(21)
      // expr -> expr Ques expr ● Colon expr | Ques
      // expr -> expr Ques expr ● Colon expr | Colon
      // expr -> expr ● Ques expr Colon expr | Colon
      // expr -> expr ● Ques expr Colon expr | Ques
      continue match lexeme.token {
          Colon => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            22
          }
          Ques => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            20
          }
          _ => break
        }
    }
    22 => {
      self.enter_state(22)
      // expr -> expr Ques expr Colon ● expr | Ques
      // expr -> expr Ques expr Colon ● expr | Colon
      // expr -> ● Var Assign expr | Colon
      // expr -> ● expr Ques expr Colon expr | Colon
      // expr -> ● Lit | Colon
      // expr -> ● Var | Colon
      // expr -> ● LParen expr RParen | Colon
      // expr -> ● Var Assign expr | Ques
      // expr -> ● expr Ques expr Colon expr | Ques
      // expr -> ● Lit | Ques
      // expr -> ● Var | Ques
      // expr -> ● LParen expr RParen | Ques
      continue match lexeme.token {
          Var => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            13
          }
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan5()
            14
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            15
          }
          _ => break
        }
    }
    23 => {
      self.enter_state(23)
      // expr -> expr Ques expr Colon expr ● | Ques
      // expr -> expr Ques expr Colon expr ● | Colon
      // expr -> expr ● Ques expr Colon expr | Colon
      // expr -> expr ● Ques expr Colon expr | Ques
      continue match lexeme.token {
          Ques => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            20
          }
          Colon => { // reduce
            let span = self.span_stack[self.span_stack.length() - 5:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Expr(x4)
            // ignore Node [x3 : Colon]
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Triple(x0, x2, x4) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              4 => 5
              8 => 9
              11 => 12
              15 => 16
              18 => 19
              20 => 21
              22 => 23
              24 => 25
              26 => 27
              29 => 30
              31 => 32
              33 => 34
              _ => break
            }
          }
          _ => break
        }
    }
    24 => {
      self.enter_state(24)
      // expr -> expr Ques expr Colon ● expr | RParen
      // expr -> expr Ques expr Colon ● expr | Ques
      // expr -> ● Var Assign expr | Ques
      // expr -> ● expr Ques expr Colon expr | Ques
      // expr -> ● Lit | Ques
      // expr -> ● Var | Ques
      // expr -> ● LParen expr RParen | Ques
      // expr -> ● Var Assign expr | RParen
      // expr -> ● expr Ques expr Colon expr | RParen
      // expr -> ● Lit | RParen
      // expr -> ● Var | RParen
      // expr -> ● LParen expr RParen | RParen
      continue match lexeme.token {
          Var => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan4()
            6
          }
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            7
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            8
          }
          _ => break
        }
    }
    25 => {
      self.enter_state(25)
      // expr -> expr Ques expr Colon expr ● | RParen
      // expr -> expr Ques expr Colon expr ● | Ques
      // expr -> expr ● Ques expr Colon expr | Ques
      // expr -> expr ● Ques expr Colon expr | RParen
      continue match lexeme.token {
          Ques => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            11
          }
          RParen => { // reduce
            let span = self.span_stack[self.span_stack.length() - 5:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Expr(x4)
            // ignore Node [x3 : Colon]
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Triple(x0, x2, x4) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              4 => 5
              8 => 9
              11 => 12
              15 => 16
              18 => 19
              20 => 21
              22 => 23
              24 => 25
              26 => 27
              29 => 30
              31 => 32
              33 => 34
              _ => break
            }
          }
          _ => break
        }
    }
    26 => {
      self.enter_state(26)
      // expr -> Var Assign ● expr | RParen
      // expr -> Var Assign ● expr | Ques
      // expr -> ● Var Assign expr | Ques
      // expr -> ● expr Ques expr Colon expr | Ques
      // expr -> ● Lit | Ques
      // expr -> ● Var | Ques
      // expr -> ● LParen expr RParen | Ques
      // expr -> ● Var Assign expr | RParen
      // expr -> ● expr Ques expr Colon expr | RParen
      // expr -> ● Lit | RParen
      // expr -> ● Var | RParen
      // expr -> ● LParen expr RParen | RParen
      continue match lexeme.token {
          Var => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan4()
            6
          }
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            7
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            8
          }
          _ => break
        }
    }
    27 => {
      self.enter_state(27)
      // expr -> Var Assign expr ● | RParen
      // expr -> Var Assign expr ● | Ques
      // expr -> expr ● Ques expr Colon expr | Ques
      // expr -> expr ● Ques expr Colon expr | RParen
      continue match lexeme.token {
          Ques => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            11
          }
          RParen => { // reduce
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
            // ignore Node [x1 : Assign]
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = Expr::Assign(x0, x2) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              4 => 5
              8 => 9
              11 => 12
              15 => 16
              18 => 19
              20 => 21
              22 => 23
              24 => 25
              26 => 27
              29 => 30
              31 => 32
              33 => 34
              _ => break
            }
          }
          _ => break
        }
    }
    28 => {
      self.enter_state(28)
      // expr -> LParen expr RParen ● | LAURUS_EOF
      // expr -> LParen expr RParen ● | Ques
      continue match lexeme.token {
          LAURUS_EOF | Ques => { // reduce
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
              4 => 5
              8 => 9
              11 => 12
              15 => 16
              18 => 19
              20 => 21
              22 => 23
              24 => 25
              26 => 27
              29 => 30
              31 => 32
              33 => 34
              _ => break
            }
          }
          _ => break
        }
    }
    29 => {
      self.enter_state(29)
      // expr -> Var Assign ● expr | LAURUS_EOF
      // expr -> Var Assign ● expr | Ques
      // expr -> ● Var Assign expr | Ques
      // expr -> ● expr Ques expr Colon expr | Ques
      // expr -> ● Lit | Ques
      // expr -> ● Var | Ques
      // expr -> ● LParen expr RParen | Ques
      // expr -> ● Var Assign expr | LAURUS_EOF
      // expr -> ● expr Ques expr Colon expr | LAURUS_EOF
      // expr -> ● Lit | LAURUS_EOF
      // expr -> ● Var | LAURUS_EOF
      // expr -> ● LParen expr RParen | LAURUS_EOF
      continue match lexeme.token {
          Var => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan2()
            2
          }
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan1()
            3
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            4
          }
          _ => break
        }
    }
    30 => {
      self.enter_state(30)
      // expr -> Var Assign expr ● | LAURUS_EOF
      // expr -> Var Assign expr ● | Ques
      // expr -> expr ● Ques expr Colon expr | Ques
      // expr -> expr ● Ques expr Colon expr | LAURUS_EOF
      continue match lexeme.token {
          Ques => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            31
          }
          LAURUS_EOF => { // reduce
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
            // ignore Node [x1 : Assign]
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = Expr::Assign(x0, x2) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              4 => 5
              8 => 9
              11 => 12
              15 => 16
              18 => 19
              20 => 21
              22 => 23
              24 => 25
              26 => 27
              29 => 30
              31 => 32
              33 => 34
              _ => break
            }
          }
          _ => break
        }
    }
    31 => {
      self.enter_state(31)
      // expr -> expr Ques ● expr Colon expr | Ques
      // expr -> expr Ques ● expr Colon expr | LAURUS_EOF
      // expr -> ● Var Assign expr | Colon
      // expr -> ● expr Ques expr Colon expr | Colon
      // expr -> ● Lit | Colon
      // expr -> ● Var | Colon
      // expr -> ● LParen expr RParen | Colon
      // expr -> ● Var Assign expr | Ques
      // expr -> ● expr Ques expr Colon expr | Ques
      // expr -> ● Lit | Ques
      // expr -> ● Var | Ques
      // expr -> ● LParen expr RParen | Ques
      continue match lexeme.token {
          Var => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            13
          }
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan5()
            14
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            15
          }
          _ => break
        }
    }
    32 => {
      self.enter_state(32)
      // expr -> expr Ques expr ● Colon expr | Ques
      // expr -> expr Ques expr ● Colon expr | LAURUS_EOF
      // expr -> expr ● Ques expr Colon expr | Colon
      // expr -> expr ● Ques expr Colon expr | Ques
      continue match lexeme.token {
          Colon => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            33
          }
          Ques => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            20
          }
          _ => break
        }
    }
    33 => {
      self.enter_state(33)
      // expr -> expr Ques expr Colon ● expr | Ques
      // expr -> expr Ques expr Colon ● expr | LAURUS_EOF
      // expr -> ● Var Assign expr | LAURUS_EOF
      // expr -> ● expr Ques expr Colon expr | LAURUS_EOF
      // expr -> ● Lit | LAURUS_EOF
      // expr -> ● Var | LAURUS_EOF
      // expr -> ● LParen expr RParen | LAURUS_EOF
      // expr -> ● Var Assign expr | Ques
      // expr -> ● expr Ques expr Colon expr | Ques
      // expr -> ● Lit | Ques
      // expr -> ● Var | Ques
      // expr -> ● LParen expr RParen | Ques
      continue match lexeme.token {
          Var => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan2()
            2
          }
          Lit => { // shift
            let node = self.lexer.get(lexeme) |> Int::from_str |> Node::Int
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan1()
            3
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            4
          }
          _ => break
        }
    }
    34 => {
      self.enter_state(34)
      // expr -> expr Ques expr Colon expr ● | Ques
      // expr -> expr Ques expr Colon expr ● | LAURUS_EOF
      // expr -> expr ● Ques expr Colon expr | LAURUS_EOF
      // expr -> expr ● Ques expr Colon expr | Ques
      continue match lexeme.token {
          Ques => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            31
          }
          LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 5:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Expr(x4)
            // ignore Node [x3 : Colon]
            guard self.node_stack.unsafe_pop() is Node::Expr(x2)
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::Expr(x0)
            let node = Expr::Triple(x0, x2, x4) |> Node::Expr
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              4 => 5
              8 => 9
              11 => 12
              15 => 16
              18 => 19
              20 => 21
              22 => 23
              24 => 25
              26 => 27
              29 => 30
              31 => 32
              33 => 34
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
