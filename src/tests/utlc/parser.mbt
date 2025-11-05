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
  Term(Term)
  String(String)
} derive(Show)

///|
pub fn Parser::parse(self : Self) -> Term raise LexerError {
  let mut lexeme = self.lexer.scan0()
  loop 0 {
    0 => {
      self.enter_state(0)
      // %start -> ● term | LAURUS_EOF
      // term -> ● Var | LAURUS_EOF
      // term -> ● Lam Var Arr term | LAURUS_EOF
      // term -> ● term term | LAURUS_EOF
      // term -> ● LParen term RParen | LAURUS_EOF
      // term -> ● Var | Var
      // term -> ● Var | Lam
      // term -> ● Var | LParen
      // term -> ● Lam Var Arr term | Var
      // term -> ● Lam Var Arr term | Lam
      // term -> ● Lam Var Arr term | LParen
      // term -> ● term term | Var
      // term -> ● term term | Lam
      // term -> ● term term | LParen
      // term -> ● LParen term RParen | Var
      // term -> ● LParen term RParen | Lam
      // term -> ● LParen term RParen | LParen
      continue match lexeme.token {
          Var => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan2()
            2
          }
          Lam => { // shift
            // ignore the old lexeme
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
      // %start -> term ● | LAURUS_EOF
      // term -> term ● term | LAURUS_EOF
      // term -> term ● term | Var
      // term -> term ● term | Lam
      // term -> term ● term | LParen
      // term -> ● Var | LParen
      // term -> ● Lam Var Arr term | LParen
      // term -> ● term term | LParen
      // term -> ● LParen term RParen | LParen
      // term -> ● Var | Var
      // term -> ● Var | Lam
      // term -> ● Lam Var Arr term | Var
      // term -> ● Lam Var Arr term | Lam
      // term -> ● term term | Var
      // term -> ● term term | Lam
      // term -> ● LParen term RParen | Var
      // term -> ● LParen term RParen | Lam
      // term -> ● Var | LAURUS_EOF
      // term -> ● Lam Var Arr term | LAURUS_EOF
      // term -> ● term term | LAURUS_EOF
      // term -> ● LParen term RParen | LAURUS_EOF
      continue match lexeme.token {
          Var => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan2()
            2
          }
          Lam => { // shift
            // ignore the old lexeme
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
          LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Term(x0)
            let node = x0 |> Node::Term
            self.node_stack.push(node)
            break
          }
          _ => break
        }
    }
    2 => {
      self.enter_state(2)
      // term -> Var ● | LAURUS_EOF
      // term -> Var ● | Var
      // term -> Var ● | Lam
      // term -> Var ● | LParen
      continue match lexeme.token {
          LAURUS_EOF | Var | Lam | LParen => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = Term::Var(x0) |> Node::Term
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              1 | 18 => 19
              4 => 5
              5 | 9 | 14 => 11
              8 => 9
              13 => 14
              17 => 18
              _ => break
            }
          }
          _ => break
        }
    }
    3 => {
      self.enter_state(3)
      // term -> Lam ● Var Arr term | LAURUS_EOF
      // term -> Lam ● Var Arr term | Var
      // term -> Lam ● Var Arr term | Lam
      // term -> Lam ● Var Arr term | LParen
      continue match lexeme.token {
          Var => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            16
          }
          _ => break
        }
    }
    4 => {
      self.enter_state(4)
      // term -> LParen ● term RParen | LAURUS_EOF
      // term -> LParen ● term RParen | Var
      // term -> LParen ● term RParen | Lam
      // term -> LParen ● term RParen | LParen
      // term -> ● Var | RParen
      // term -> ● Lam Var Arr term | RParen
      // term -> ● term term | RParen
      // term -> ● LParen term RParen | RParen
      // term -> ● Var | Var
      // term -> ● Var | Lam
      // term -> ● Var | LParen
      // term -> ● Lam Var Arr term | Var
      // term -> ● Lam Var Arr term | Lam
      // term -> ● Lam Var Arr term | LParen
      // term -> ● term term | Var
      // term -> ● term term | Lam
      // term -> ● term term | LParen
      // term -> ● LParen term RParen | Var
      // term -> ● LParen term RParen | Lam
      // term -> ● LParen term RParen | LParen
      continue match lexeme.token {
          Var => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan4()
            6
          }
          Lam => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan1()
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
      // term -> LParen term ● RParen | LAURUS_EOF
      // term -> LParen term ● RParen | Var
      // term -> LParen term ● RParen | Lam
      // term -> LParen term ● RParen | LParen
      // term -> term ● term | RParen
      // term -> term ● term | Var
      // term -> term ● term | Lam
      // term -> term ● term | LParen
      // term -> ● Var | LParen
      // term -> ● Lam Var Arr term | LParen
      // term -> ● term term | LParen
      // term -> ● LParen term RParen | LParen
      // term -> ● Var | Var
      // term -> ● Var | Lam
      // term -> ● Lam Var Arr term | Var
      // term -> ● Lam Var Arr term | Lam
      // term -> ● term term | Var
      // term -> ● term term | Lam
      // term -> ● LParen term RParen | Var
      // term -> ● LParen term RParen | Lam
      // term -> ● Var | RParen
      // term -> ● Lam Var Arr term | RParen
      // term -> ● term term | RParen
      // term -> ● LParen term RParen | RParen
      continue match lexeme.token {
          RParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan2()
            15
          }
          Var => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan4()
            6
          }
          Lam => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan1()
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
    6 => {
      self.enter_state(6)
      // term -> Var ● | RParen
      // term -> Var ● | Var
      // term -> Var ● | Lam
      // term -> Var ● | LParen
      continue match lexeme.token {
          RParen | Var | Lam | LParen => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = Term::Var(x0) |> Node::Term
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              1 | 18 => 19
              4 => 5
              5 | 9 | 14 => 11
              8 => 9
              13 => 14
              17 => 18
              _ => break
            }
          }
          _ => break
        }
    }
    7 => {
      self.enter_state(7)
      // term -> Lam ● Var Arr term | RParen
      // term -> Lam ● Var Arr term | Var
      // term -> Lam ● Var Arr term | Lam
      // term -> Lam ● Var Arr term | LParen
      continue match lexeme.token {
          Var => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            12
          }
          _ => break
        }
    }
    8 => {
      self.enter_state(8)
      // term -> LParen ● term RParen | RParen
      // term -> LParen ● term RParen | Var
      // term -> LParen ● term RParen | Lam
      // term -> LParen ● term RParen | LParen
      // term -> ● Var | RParen
      // term -> ● Lam Var Arr term | RParen
      // term -> ● term term | RParen
      // term -> ● LParen term RParen | RParen
      // term -> ● Var | Var
      // term -> ● Var | Lam
      // term -> ● Var | LParen
      // term -> ● Lam Var Arr term | Var
      // term -> ● Lam Var Arr term | Lam
      // term -> ● Lam Var Arr term | LParen
      // term -> ● term term | Var
      // term -> ● term term | Lam
      // term -> ● term term | LParen
      // term -> ● LParen term RParen | Var
      // term -> ● LParen term RParen | Lam
      // term -> ● LParen term RParen | LParen
      continue match lexeme.token {
          Var => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan4()
            6
          }
          Lam => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan1()
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
      // term -> LParen term ● RParen | RParen
      // term -> LParen term ● RParen | Var
      // term -> LParen term ● RParen | Lam
      // term -> LParen term ● RParen | LParen
      // term -> term ● term | RParen
      // term -> term ● term | Var
      // term -> term ● term | Lam
      // term -> term ● term | LParen
      // term -> ● Var | LParen
      // term -> ● Lam Var Arr term | LParen
      // term -> ● term term | LParen
      // term -> ● LParen term RParen | LParen
      // term -> ● Var | Var
      // term -> ● Var | Lam
      // term -> ● Lam Var Arr term | Var
      // term -> ● Lam Var Arr term | Lam
      // term -> ● term term | Var
      // term -> ● term term | Lam
      // term -> ● LParen term RParen | Var
      // term -> ● LParen term RParen | Lam
      // term -> ● Var | RParen
      // term -> ● Lam Var Arr term | RParen
      // term -> ● term term | RParen
      // term -> ● LParen term RParen | RParen
      continue match lexeme.token {
          RParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan4()
            10
          }
          Var => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan4()
            6
          }
          Lam => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan1()
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
    10 => {
      self.enter_state(10)
      // term -> LParen term RParen ● | RParen
      // term -> LParen term RParen ● | Var
      // term -> LParen term RParen ● | Lam
      // term -> LParen term RParen ● | LParen
      continue match lexeme.token {
          RParen | Var | Lam | LParen => { // reduce
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
            guard self.node_stack.unsafe_pop() is Node::Term(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::Term
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              1 | 18 => 19
              4 => 5
              5 | 9 | 14 => 11
              8 => 9
              13 => 14
              17 => 18
              _ => break
            }
          }
          _ => break
        }
    }
    11 => {
      self.enter_state(11)
      // term -> term term ● | RParen
      // term -> term term ● | Var
      // term -> term term ● | Lam
      // term -> term term ● | LParen
      continue match lexeme.token {
          RParen | Var | Lam | LParen => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Term(x1)
            guard self.node_stack.unsafe_pop() is Node::Term(x0)
            let node = Term::App(x0, x1) |> Node::Term
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              1 | 18 => 19
              4 => 5
              5 | 9 | 14 => 11
              8 => 9
              13 => 14
              17 => 18
              _ => break
            }
          }
          _ => break
        }
    }
    12 => {
      self.enter_state(12)
      // term -> Lam Var ● Arr term | RParen
      // term -> Lam Var ● Arr term | Var
      // term -> Lam Var ● Arr term | Lam
      // term -> Lam Var ● Arr term | LParen
      continue match lexeme.token {
          Arr => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            13
          }
          _ => break
        }
    }
    13 => {
      self.enter_state(13)
      // term -> Lam Var Arr ● term | RParen
      // term -> Lam Var Arr ● term | Var
      // term -> Lam Var Arr ● term | Lam
      // term -> Lam Var Arr ● term | LParen
      // term -> ● Var | LParen
      // term -> ● Lam Var Arr term | LParen
      // term -> ● term term | LParen
      // term -> ● LParen term RParen | LParen
      // term -> ● Var | Var
      // term -> ● Var | Lam
      // term -> ● Lam Var Arr term | Var
      // term -> ● Lam Var Arr term | Lam
      // term -> ● term term | Var
      // term -> ● term term | Lam
      // term -> ● LParen term RParen | Var
      // term -> ● LParen term RParen | Lam
      // term -> ● Var | RParen
      // term -> ● Lam Var Arr term | RParen
      // term -> ● term term | RParen
      // term -> ● LParen term RParen | RParen
      continue match lexeme.token {
          Var => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan4()
            6
          }
          Lam => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan1()
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
    14 => {
      self.enter_state(14)
      // term -> Lam Var Arr term ● | RParen
      // term -> Lam Var Arr term ● | Var
      // term -> Lam Var Arr term ● | Lam
      // term -> Lam Var Arr term ● | LParen
      // term -> term ● term | LParen
      // term -> term ● term | Var
      // term -> term ● term | Lam
      // term -> term ● term | RParen
      // term -> ● Var | RParen
      // term -> ● Lam Var Arr term | RParen
      // term -> ● term term | RParen
      // term -> ● LParen term RParen | RParen
      // term -> ● Var | Var
      // term -> ● Var | Lam
      // term -> ● Var | LParen
      // term -> ● Lam Var Arr term | Var
      // term -> ● Lam Var Arr term | Lam
      // term -> ● Lam Var Arr term | LParen
      // term -> ● term term | Var
      // term -> ● term term | Lam
      // term -> ● term term | LParen
      // term -> ● LParen term RParen | Var
      // term -> ● LParen term RParen | Lam
      // term -> ● LParen term RParen | LParen
      continue match lexeme.token {
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            8
          }
          RParen | Var | Lam => { // reduce
            let span = self.span_stack[self.span_stack.length() - 4:].iter()
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
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Term(x3)
            // ignore Node [x2 : Arr]
            guard self.node_stack.unsafe_pop() is Node::String(x1)
            // ignore Node [x0 : Lam]
            let node = Term::Abs(x1, x3) |> Node::Term
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              1 | 18 => 19
              4 => 5
              5 | 9 | 14 => 11
              8 => 9
              13 => 14
              17 => 18
              _ => break
            }
          }
          _ => break
        }
    }
    15 => {
      self.enter_state(15)
      // term -> LParen term RParen ● | LAURUS_EOF
      // term -> LParen term RParen ● | Var
      // term -> LParen term RParen ● | Lam
      // term -> LParen term RParen ● | LParen
      continue match lexeme.token {
          LAURUS_EOF | Var | Lam | LParen => { // reduce
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
            guard self.node_stack.unsafe_pop() is Node::Term(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::Term
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              1 | 18 => 19
              4 => 5
              5 | 9 | 14 => 11
              8 => 9
              13 => 14
              17 => 18
              _ => break
            }
          }
          _ => break
        }
    }
    16 => {
      self.enter_state(16)
      // term -> Lam Var ● Arr term | LAURUS_EOF
      // term -> Lam Var ● Arr term | Var
      // term -> Lam Var ● Arr term | Lam
      // term -> Lam Var ● Arr term | LParen
      continue match lexeme.token {
          Arr => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            17
          }
          _ => break
        }
    }
    17 => {
      self.enter_state(17)
      // term -> Lam Var Arr ● term | LAURUS_EOF
      // term -> Lam Var Arr ● term | Var
      // term -> Lam Var Arr ● term | Lam
      // term -> Lam Var Arr ● term | LParen
      // term -> ● Var | LParen
      // term -> ● Lam Var Arr term | LParen
      // term -> ● term term | LParen
      // term -> ● LParen term RParen | LParen
      // term -> ● Var | Var
      // term -> ● Var | Lam
      // term -> ● Lam Var Arr term | Var
      // term -> ● Lam Var Arr term | Lam
      // term -> ● term term | Var
      // term -> ● term term | Lam
      // term -> ● LParen term RParen | Var
      // term -> ● LParen term RParen | Lam
      // term -> ● Var | LAURUS_EOF
      // term -> ● Lam Var Arr term | LAURUS_EOF
      // term -> ● term term | LAURUS_EOF
      // term -> ● LParen term RParen | LAURUS_EOF
      continue match lexeme.token {
          Var => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan2()
            2
          }
          Lam => { // shift
            // ignore the old lexeme
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
    18 => {
      self.enter_state(18)
      // term -> Lam Var Arr term ● | LAURUS_EOF
      // term -> Lam Var Arr term ● | Var
      // term -> Lam Var Arr term ● | Lam
      // term -> Lam Var Arr term ● | LParen
      // term -> term ● term | LParen
      // term -> term ● term | Var
      // term -> term ● term | Lam
      // term -> term ● term | LAURUS_EOF
      // term -> ● Var | LAURUS_EOF
      // term -> ● Lam Var Arr term | LAURUS_EOF
      // term -> ● term term | LAURUS_EOF
      // term -> ● LParen term RParen | LAURUS_EOF
      // term -> ● Var | Var
      // term -> ● Var | Lam
      // term -> ● Var | LParen
      // term -> ● Lam Var Arr term | Var
      // term -> ● Lam Var Arr term | Lam
      // term -> ● Lam Var Arr term | LParen
      // term -> ● term term | Var
      // term -> ● term term | Lam
      // term -> ● term term | LParen
      // term -> ● LParen term RParen | Var
      // term -> ● LParen term RParen | Lam
      // term -> ● LParen term RParen | LParen
      continue match lexeme.token {
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            4
          }
          LAURUS_EOF | Var | Lam => { // reduce
            let span = self.span_stack[self.span_stack.length() - 4:].iter()
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
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Term(x3)
            // ignore Node [x2 : Arr]
            guard self.node_stack.unsafe_pop() is Node::String(x1)
            // ignore Node [x0 : Lam]
            let node = Term::Abs(x1, x3) |> Node::Term
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              1 | 18 => 19
              4 => 5
              5 | 9 | 14 => 11
              8 => 9
              13 => 14
              17 => 18
              _ => break
            }
          }
          _ => break
        }
    }
    19 => {
      self.enter_state(19)
      // term -> term term ● | LParen
      // term -> term term ● | Var
      // term -> term term ● | Lam
      // term -> term term ● | LAURUS_EOF
      continue match lexeme.token {
          LParen | Var | Lam | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Term(x1)
            guard self.node_stack.unsafe_pop() is Node::Term(x0)
            let node = Term::App(x0, x1) |> Node::Term
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              0 => 1
              1 | 18 => 19
              4 => 5
              5 | 9 | 14 => 11
              8 => 9
              13 => 14
              17 => 18
              _ => break
            }
          }
          _ => break
        }
    }
    _ => break
  }
  guard self.node_stack[0] is Term(node)
  node
}
