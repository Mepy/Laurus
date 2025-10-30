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
  Laurus(Laurus)
  TokenConv(TokenConv)
  RegExp(RegExp)
  Array_LB_Range_RB_(Array[Range])
  Range(Range)
  Char(Char)
  SortType(SortType)
  Generics(Generics)
  Array_LB_Rule_RB_(Array[Rule])
  Rule(Rule)
  Priority(Priority)
  ShiftReduce(ShiftReduce)
  Action(Action)
  Array_LB_Symbol_RB_(Array[Symbol])
  Symbol(Symbol)
  String(String)
} derive(Show)

///|
pub fn Parser::parse(self : Self) -> Laurus? {
  let mut lexeme = self.lexer.scan0()
  loop 0 {
    0 => {
      self.enter_state(0)
      continue match lexeme.token {
          LAURUS_EOF | SortName | TokenName | Percent | CommentHead => { // reduce
            let loc = self.lexer.cur_loc()
            let span = Span::leaf(loc, loc)
            self.span_stack.push(span)
            let node = Laurus::new() |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          _ => break
        }
    }
    1 => {
      self.enter_state(1)
      continue match lexeme.token {
          CommentHead => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan4()
            2
          }
          Percent => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            3
          }
          TokenName => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan2()
            4
          }
          SortName => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan1()
            5
          }
          LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = x0 |> Node::Laurus
            self.node_stack.push(node)
            break
          }
          _ => break
        }
    }
    2 => {
      self.enter_state(2)
      continue match lexeme.token {
          CommentBody => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            122
          }
          _ => break
        }
    }
    3 => {
      self.enter_state(3)
      continue match lexeme.token {
          Space => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            92
          }
          Start => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan5()
            93
          }
          _ => break
        }
    }
    4 => {
      self.enter_state(4)
      continue match lexeme.token {
          Eq => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan7()
            41
          }
          _ => break
        }
    }
    5 => {
      self.enter_state(5)
      continue match lexeme.token {
          Colon => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan8()
            7
          }
          LBrace => { // reduce
            let loc = self.lexer.cur_loc()
            let span = Span::leaf(loc, loc)
            self.span_stack.push(span)
            let node = SortType::Ignore |> Node::SortType
            self.node_stack.push(node)
            6
          }
          _ => break
        }
    }
    6 => {
      self.enter_state(6)
      continue match lexeme.token {
          LBrace => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan9()
            16
          }
          _ => break
        }
    }
    7 => {
      self.enter_state(7)
      continue match lexeme.token {
          TypeName => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan10()
            8
          }
          _ => break
        }
    }
    8 => {
      self.enter_state(8)
      continue match lexeme.token {
          LBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan8()
            9
          }
          LBrace => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::String(x1)
            // ignore Node [x0 : Colon]
            let node = SortType::Atom(x1) |> Node::SortType
            self.node_stack.push(node)
            6
          }
          _ => break
        }
    }
    9 => {
      self.enter_state(9)
      continue match lexeme.token {
          TypeName => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan11()
            11
          }
          _ => break
        }
    }
    10 => {
      self.enter_state(10)
      continue match lexeme.token {
          RBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan12()
            15
          }
          _ => break
        }
    }
    11 => {
      self.enter_state(11)
      continue match lexeme.token {
          LBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan8()
            12
          }
          RBrack => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = Generics::Atom(x0) |> Node::Generics
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              9 => 10
              12 => 13
              _ => break
            }
          }
          _ => break
        }
    }
    12 => {
      self.enter_state(12)
      continue match lexeme.token {
          TypeName => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan11()
            11
          }
          _ => break
        }
    }
    13 => {
      self.enter_state(13)
      continue match lexeme.token {
          RBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan13()
            14
          }
          _ => break
        }
    }
    14 => {
      self.enter_state(14)
      continue match lexeme.token {
          RBrack => { // reduce
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
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Generics(x2)
            // ignore Node [x1 : LBrack]
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = Generics::Gen(x0, x2) |> Node::Generics
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              9 => 10
              12 => 13
              _ => break
            }
          }
          _ => break
        }
    }
    15 => {
      self.enter_state(15)
      continue match lexeme.token {
          LBrace => { // reduce
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
            // ignore Node [x4 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Generics(x3)
            // ignore Node [x2 : LBrack]
            guard self.node_stack.unsafe_pop() is Node::String(x1)
            // ignore Node [x0 : Colon]
            let node = SortType::Gen(x1, x3) |> Node::SortType
            self.node_stack.push(node)
            6
          }
          _ => break
        }
    }
    16 => {
      self.enter_state(16)
      continue match lexeme.token {
          RBrace | Or | Lt => { // reduce
            let loc = self.lexer.cur_loc()
            let span = Span::leaf(loc, loc)
            self.span_stack.push(span)
            let node = Array::empty() |> Node::Array_LB_Rule_RB_
            self.node_stack.push(node)
            17
          }
          _ => break
        }
    }
    17 => {
      self.enter_state(17)
      continue match lexeme.token {
          RBrace => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            18
          }
          Or => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan14()
            21
          }
          Lt => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan14()
            22
          }
          _ => break
        }
    }
    18 => {
      self.enter_state(18)
      continue match lexeme.token {
          LAURUS_EOF | SortName | TokenName | Percent | CommentHead => { // reduce
            let span = self.span_stack[self.span_stack.length() - 6:].iter()
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
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x5 : RBrace]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Rule_RB_(x4)
            // ignore Node [x3 : LBrace]
            guard self.node_stack.unsafe_pop() is Node::SortType(x2)
            guard self.node_stack.unsafe_pop() is Node::String(x1)
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::add_sort(x0, x1, x2, x4) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          _ => break
        }
    }
    19 => {
      self.enter_state(19)
      continue match lexeme.token {
          RBrace | Or | Lt => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Rule(x1)
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Rule_RB_(x0)
            let node = Array::snoc(x0, x1) |> Node::Array_LB_Rule_RB_
            self.node_stack.push(node)
            17
          }
          _ => break
        }
    }
    20 => {
      self.enter_state(20)
      continue match lexeme.token {
          Reduce => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan15()
            24
          }
          Shift => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan15()
            25
          }
          ConstructorName | MethodName | LParen => { // reduce
            let loc = self.lexer.cur_loc()
            let span = Span::leaf(loc, loc)
            self.span_stack.push(span)
            let node = ShiftReduce::Reduce |> Node::ShiftReduce
            self.node_stack.push(node)
            23
          }
          _ => break
        }
    }
    21 => {
      self.enter_state(21)
      continue match lexeme.token {
          Reduce | Shift | ConstructorName | MethodName | LParen => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x0 : Or]
            let node = Priority::Equal |> Node::Priority
            self.node_stack.push(node)
            20
          }
          _ => break
        }
    }
    22 => {
      self.enter_state(22)
      continue match lexeme.token {
          Reduce | Shift | ConstructorName | MethodName | LParen => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x0 : Lt]
            let node = Priority::Higher |> Node::Priority
            self.node_stack.push(node)
            20
          }
          _ => break
        }
    }
    23 => {
      self.enter_state(23)
      continue match lexeme.token {
          ConstructorName => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan16()
            27
          }
          MethodName => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan16()
            28
          }
          LParen => { // reduce
            let loc = self.lexer.cur_loc()
            let span = Span::leaf(loc, loc)
            self.span_stack.push(span)
            let node = Action::Wrapper |> Node::Action
            self.node_stack.push(node)
            26
          }
          _ => break
        }
    }
    24 => {
      self.enter_state(24)
      continue match lexeme.token {
          ConstructorName | MethodName | LParen => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x0 : Reduce]
            let node = ShiftReduce::Reduce |> Node::ShiftReduce
            self.node_stack.push(node)
            23
          }
          _ => break
        }
    }
    25 => {
      self.enter_state(25)
      continue match lexeme.token {
          ConstructorName | MethodName | LParen => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x0 : Shift]
            let node = ShiftReduce::Shift |> Node::ShiftReduce
            self.node_stack.push(node)
            23
          }
          _ => break
        }
    }
    26 => {
      self.enter_state(26)
      continue match lexeme.token {
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan17()
            29
          }
          _ => break
        }
    }
    27 => {
      self.enter_state(27)
      continue match lexeme.token {
          LParen => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = Action::Constructor(x0) |> Node::Action
            self.node_stack.push(node)
            26
          }
          _ => break
        }
    }
    28 => {
      self.enter_state(28)
      continue match lexeme.token {
          LParen => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = Action::Method(x0) |> Node::Action
            self.node_stack.push(node)
            26
          }
          _ => break
        }
    }
    29 => {
      self.enter_state(29)
      continue match lexeme.token {
          RParen | Symbol | LBrack => { // reduce
            let loc = self.lexer.cur_loc()
            let span = Span::leaf(loc, loc)
            self.span_stack.push(span)
            let node = Array::empty() |> Node::Array_LB_Symbol_RB_
            self.node_stack.push(node)
            30
          }
          _ => break
        }
    }
    30 => {
      self.enter_state(30)
      continue match lexeme.token {
          RParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan9()
            31
          }
          Symbol => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan17()
            33
          }
          LBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan18()
            34
          }
          _ => break
        }
    }
    31 => {
      self.enter_state(31)
      continue match lexeme.token {
          Lt | Or | RBrace => { // reduce
            let span = self.span_stack[self.span_stack.length() - 6:].iter()
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
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x5 : RParen]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Symbol_RB_(x4)
            // ignore Node [x3 : LParen]
            guard self.node_stack.unsafe_pop() is Node::Action(x2)
            guard self.node_stack.unsafe_pop() is Node::ShiftReduce(x1)
            guard self.node_stack.unsafe_pop() is Node::Priority(x0)
            let node = Rule::{
                priority: x0,
                shift_reduce: x1,
                action: x2,
                symbols: x4,
              }
              |> Node::Rule
            self.node_stack.push(node)
            19
          }
          _ => break
        }
    }
    32 => {
      self.enter_state(32)
      continue match lexeme.token {
          RParen | Symbol | LBrack => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Symbol(x1)
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Symbol_RB_(x0)
            let node = Array::snoc(x0, x1) |> Node::Array_LB_Symbol_RB_
            self.node_stack.push(node)
            30
          }
          _ => break
        }
    }
    33 => {
      self.enter_state(33)
      continue match lexeme.token {
          LBrack | Symbol | RParen => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = Symbol::Unnamed(x0) |> Node::Symbol
            self.node_stack.push(node)
            32
          }
          _ => break
        }
    }
    34 => {
      self.enter_state(34)
      continue match lexeme.token {
          FieldName => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan19()
            35
          }
          _ => break
        }
    }
    35 => {
      self.enter_state(35)
      continue match lexeme.token {
          Colon => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan20()
            36
          }
          Tilde => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan13()
            37
          }
          _ => break
        }
    }
    36 => {
      self.enter_state(36)
      continue match lexeme.token {
          Symbol => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan13()
            39
          }
          _ => break
        }
    }
    37 => {
      self.enter_state(37)
      continue match lexeme.token {
          RBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan17()
            38
          }
          _ => break
        }
    }
    38 => {
      self.enter_state(38)
      continue match lexeme.token {
          LBrack | Symbol | RParen => { // reduce
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
            // ignore Node [x3 : RBrack]
            // ignore Node [x2 : Tilde]
            guard self.node_stack.unsafe_pop() is Node::String(x1)
            // ignore Node [x0 : LBrack]
            let node = Symbol::NamedAbbrev(field_name=x1) |> Node::Symbol
            self.node_stack.push(node)
            32
          }
          _ => break
        }
    }
    39 => {
      self.enter_state(39)
      continue match lexeme.token {
          RBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan17()
            40
          }
          _ => break
        }
    }
    40 => {
      self.enter_state(40)
      continue match lexeme.token {
          LBrack | Symbol | RParen => { // reduce
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
            // ignore Node [x4 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::String(x3)
            // ignore Node [x2 : Colon]
            guard self.node_stack.unsafe_pop() is Node::String(x1)
            // ignore Node [x0 : LBrack]
            let node = Symbol::Named(field_name=x1, x3) |> Node::Symbol
            self.node_stack.push(node)
            32
          }
          _ => break
        }
    }
    41 => {
      self.enter_state(41)
      continue match lexeme.token {
          TypeName => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan21()
            43
          }
          LParen => { // reduce
            let loc = self.lexer.cur_loc()
            let span = Span::leaf(loc, loc)
            self.span_stack.push(span)
            let node = TokenConv::Ignore |> Node::TokenConv
            self.node_stack.push(node)
            42
          }
          _ => break
        }
    }
    42 => {
      self.enter_state(42)
      continue match lexeme.token {
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            46
          }
          _ => break
        }
    }
    43 => {
      self.enter_state(43)
      continue match lexeme.token {
          ColonColon => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan22()
            44
          }
          LParen => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::BuiltIn(x0) |> Node::TokenConv
            self.node_stack.push(node)
            42
          }
          _ => break
        }
    }
    44 => {
      self.enter_state(44)
      continue match lexeme.token {
          MethodName => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan16()
            45
          }
          _ => break
        }
    }
    45 => {
      self.enter_state(45)
      continue match lexeme.token {
          LParen => { // reduce
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
            guard self.node_stack.unsafe_pop() is Node::String(x2)
            // ignore Node [x1 : ColonColon]
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::Interpret(type_name=x0, parse_func_name=x2)
              |> Node::TokenConv
            self.node_stack.push(node)
            42
          }
          _ => break
        }
    }
    46 => {
      self.enter_state(46)
      continue match lexeme.token {
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            49
          }
          LBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan25()
            50
          }
          Dot => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            51
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            52
          }
          Esc => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan23()
            53
          }
          _ => break
        }
    }
    47 => {
      self.enter_state(47)
      continue match lexeme.token {
          RParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            91
          }
          Or => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            83
          }
          Star => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            85
          }
          Plus => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            86
          }
          Ques => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            87
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            49
          }
          LBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan25()
            50
          }
          Dot => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            51
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            52
          }
          Esc => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan23()
            53
          }
          _ => break
        }
    }
    48 => {
      self.enter_state(48)
      continue match lexeme.token {
          RParen
          | Ques
          | Plus
          | Star
          | EscNo
          | Esc
          | LParen
          | LBrack
          | Dot
          | Or => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 47
              47 | 81 | 89 | 90 | 112 => 84
              49 => 81
              83 => 90
              88 => 89
              92 => 95
              95 | 120 | 121 => 115
              97 => 112
              114 => 121
              119 => 120
              _ => break
            }
          }
          _ => break
        }
    }
    49 => {
      self.enter_state(49)
      continue match lexeme.token {
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            49
          }
          LBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan25()
            50
          }
          Dot => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            51
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            52
          }
          Esc => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan23()
            53
          }
          _ => break
        }
    }
    50 => {
      self.enter_state(50)
      continue match lexeme.token {
          Caret => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan27()
            59
          }
          RBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            60
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan26()
            63
          }
          Esc => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan23()
            64
          }
          _ => break
        }
    }
    51 => {
      self.enter_state(51)
      continue match lexeme.token {
          RParen
          | Ques
          | Plus
          | Star
          | EscNo
          | Esc
          | LParen
          | LBrack
          | Dot
          | Or => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 47
              47 | 81 | 89 | 90 | 112 => 84
              49 => 81
              83 => 90
              88 => 89
              92 => 95
              95 | 120 | 121 => 115
              97 => 112
              114 => 121
              119 => 120
              _ => break
            }
          }
          _ => break
        }
    }
    52 => {
      self.enter_state(52)
      continue match lexeme.token {
          RParen
          | Ques
          | Plus
          | Star
          | Dot
          | LBrack
          | LParen
          | Esc
          | EscNo
          | Or => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 | 47 | 49 | 81 | 83 | 88 | 89 | 90 | 97 | 112 => 48
              50 | 58 | 59 | 77 | 98 | 106 | 107 | 109 => 62
              69 => 70
              92 | 95 | 114 | 119 | 120 | 121 => 96
              _ => break
            }
          }
          _ => break
        }
    }
    53 => {
      self.enter_state(53)
      continue match lexeme.token {
          EscOrigin => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            54
          }
          EscSpace => { // shift
            let node = self.lexer.get(lexeme) |> Char::esc_space |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            55
          }
          EscU => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan28()
            56
          }
          _ => break
        }
    }
    54 => {
      self.enter_state(54)
      continue match lexeme.token {
          RParen
          | Ques
          | Plus
          | Star
          | Dot
          | LBrack
          | LParen
          | Esc
          | EscNo
          | Or => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 | 47 | 49 | 81 | 83 | 88 | 89 | 90 | 97 | 112 => 48
              50 | 58 | 59 | 77 | 98 | 106 | 107 | 109 => 62
              69 => 70
              92 | 95 | 114 | 119 | 120 | 121 => 96
              _ => break
            }
          }
          _ => break
        }
    }
    55 => {
      self.enter_state(55)
      continue match lexeme.token {
          RParen
          | Ques
          | Plus
          | Star
          | Dot
          | LBrack
          | LParen
          | Esc
          | EscNo
          | Or => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 | 47 | 49 | 81 | 83 | 88 | 89 | 90 | 97 | 112 => 48
              50 | 58 | 59 | 77 | 98 | 106 | 107 | 109 => 62
              69 => 70
              92 | 95 | 114 | 119 | 120 | 121 => 96
              _ => break
            }
          }
          _ => break
        }
    }
    56 => {
      self.enter_state(56)
      continue match lexeme.token {
          EscUnicode => { // shift
            let node = self.lexer.get(lexeme) |> Char::esc_unicode |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            57
          }
          _ => break
        }
    }
    57 => {
      self.enter_state(57)
      continue match lexeme.token {
          RParen
          | Ques
          | Plus
          | Star
          | Dot
          | LBrack
          | LParen
          | Esc
          | EscNo
          | Or => { // reduce
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
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 | 47 | 49 | 81 | 83 | 88 | 89 | 90 | 97 | 112 => 48
              50 | 58 | 59 | 77 | 98 | 106 | 107 | 109 => 62
              69 => 70
              92 | 95 | 114 | 119 | 120 | 121 => 96
              _ => break
            }
          }
          _ => break
        }
    }
    58 => {
      self.enter_state(58)
      continue match lexeme.token {
          RBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            80
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan26()
            63
          }
          Esc => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan23()
            64
          }
          _ => break
        }
    }
    59 => {
      self.enter_state(59)
      continue match lexeme.token {
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan26()
            63
          }
          Esc => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan23()
            64
          }
          _ => break
        }
    }
    60 => {
      self.enter_state(60)
      continue match lexeme.token {
          RParen
          | Ques
          | Plus
          | Star
          | EscNo
          | Esc
          | LParen
          | LBrack
          | Dot
          | Or => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 47
              47 | 81 | 89 | 90 | 112 => 84
              49 => 81
              83 => 90
              88 => 89
              92 => 95
              95 | 120 | 121 => 115
              97 => 112
              114 => 121
              119 => 120
              _ => break
            }
          }
          _ => break
        }
    }
    61 => {
      self.enter_state(61)
      continue match lexeme.token {
          RBrack | EscNo | Esc => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Range(x0)
            let node = Array::singleton(x0) |> Node::Array_LB_Range_RB_
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              50 => 58
              59 => 77
              98 => 106
              107 => 109
              _ => break
            }
          }
          _ => break
        }
    }
    62 => {
      self.enter_state(62)
      continue match lexeme.token {
          Dash => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan27()
            69
          }
          Esc | EscNo | RBrack => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = Range::single(x0) |> Node::Range
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              50 | 59 | 98 | 107 => 61
              58 | 77 | 106 | 109 => 79
              _ => break
            }
          }
          _ => break
        }
    }
    63 => {
      self.enter_state(63)
      continue match lexeme.token {
          Dash | Esc | EscNo | RBrack => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 | 47 | 49 | 81 | 83 | 88 | 89 | 90 | 97 | 112 => 48
              50 | 58 | 59 | 77 | 98 | 106 | 107 | 109 => 62
              69 => 70
              92 | 95 | 114 | 119 | 120 | 121 => 96
              _ => break
            }
          }
          _ => break
        }
    }
    64 => {
      self.enter_state(64)
      continue match lexeme.token {
          EscOrigin => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan26()
            65
          }
          EscSpace => { // shift
            let node = self.lexer.get(lexeme) |> Char::esc_space |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan26()
            66
          }
          EscU => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan28()
            67
          }
          _ => break
        }
    }
    65 => {
      self.enter_state(65)
      continue match lexeme.token {
          Dash | Esc | EscNo | RBrack => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 | 47 | 49 | 81 | 83 | 88 | 89 | 90 | 97 | 112 => 48
              50 | 58 | 59 | 77 | 98 | 106 | 107 | 109 => 62
              69 => 70
              92 | 95 | 114 | 119 | 120 | 121 => 96
              _ => break
            }
          }
          _ => break
        }
    }
    66 => {
      self.enter_state(66)
      continue match lexeme.token {
          Dash | Esc | EscNo | RBrack => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 | 47 | 49 | 81 | 83 | 88 | 89 | 90 | 97 | 112 => 48
              50 | 58 | 59 | 77 | 98 | 106 | 107 | 109 => 62
              69 => 70
              92 | 95 | 114 | 119 | 120 | 121 => 96
              _ => break
            }
          }
          _ => break
        }
    }
    67 => {
      self.enter_state(67)
      continue match lexeme.token {
          EscUnicode => { // shift
            let node = self.lexer.get(lexeme) |> Char::esc_unicode |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan26()
            68
          }
          _ => break
        }
    }
    68 => {
      self.enter_state(68)
      continue match lexeme.token {
          Dash | Esc | EscNo | RBrack => { // reduce
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
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 | 47 | 49 | 81 | 83 | 88 | 89 | 90 | 97 | 112 => 48
              50 | 58 | 59 | 77 | 98 | 106 | 107 | 109 => 62
              69 => 70
              92 | 95 | 114 | 119 | 120 | 121 => 96
              _ => break
            }
          }
          _ => break
        }
    }
    69 => {
      self.enter_state(69)
      continue match lexeme.token {
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan29()
            71
          }
          Esc => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan23()
            72
          }
          _ => break
        }
    }
    70 => {
      self.enter_state(70)
      continue match lexeme.token {
          Esc | EscNo | RBrack => { // reduce
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
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : Dash]
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = Range(x0, x2) |> Node::Range
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              50 | 59 | 98 | 107 => 61
              58 | 77 | 106 | 109 => 79
              _ => break
            }
          }
          _ => break
        }
    }
    71 => {
      self.enter_state(71)
      continue match lexeme.token {
          RBrack | EscNo | Esc => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 | 47 | 49 | 81 | 83 | 88 | 89 | 90 | 97 | 112 => 48
              50 | 58 | 59 | 77 | 98 | 106 | 107 | 109 => 62
              69 => 70
              92 | 95 | 114 | 119 | 120 | 121 => 96
              _ => break
            }
          }
          _ => break
        }
    }
    72 => {
      self.enter_state(72)
      continue match lexeme.token {
          EscOrigin => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan29()
            73
          }
          EscSpace => { // shift
            let node = self.lexer.get(lexeme) |> Char::esc_space |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan29()
            74
          }
          EscU => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan28()
            75
          }
          _ => break
        }
    }
    73 => {
      self.enter_state(73)
      continue match lexeme.token {
          RBrack | EscNo | Esc => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 | 47 | 49 | 81 | 83 | 88 | 89 | 90 | 97 | 112 => 48
              50 | 58 | 59 | 77 | 98 | 106 | 107 | 109 => 62
              69 => 70
              92 | 95 | 114 | 119 | 120 | 121 => 96
              _ => break
            }
          }
          _ => break
        }
    }
    74 => {
      self.enter_state(74)
      continue match lexeme.token {
          RBrack | EscNo | Esc => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 | 47 | 49 | 81 | 83 | 88 | 89 | 90 | 97 | 112 => 48
              50 | 58 | 59 | 77 | 98 | 106 | 107 | 109 => 62
              69 => 70
              92 | 95 | 114 | 119 | 120 | 121 => 96
              _ => break
            }
          }
          _ => break
        }
    }
    75 => {
      self.enter_state(75)
      continue match lexeme.token {
          EscUnicode => { // shift
            let node = self.lexer.get(lexeme) |> Char::esc_unicode |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan29()
            76
          }
          _ => break
        }
    }
    76 => {
      self.enter_state(76)
      continue match lexeme.token {
          RBrack | EscNo | Esc => { // reduce
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
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 | 47 | 49 | 81 | 83 | 88 | 89 | 90 | 97 | 112 => 48
              50 | 58 | 59 | 77 | 98 | 106 | 107 | 109 => 62
              69 => 70
              92 | 95 | 114 | 119 | 120 | 121 => 96
              _ => break
            }
          }
          _ => break
        }
    }
    77 => {
      self.enter_state(77)
      continue match lexeme.token {
          RBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            78
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan26()
            63
          }
          Esc => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan23()
            64
          }
          _ => break
        }
    }
    78 => {
      self.enter_state(78)
      continue match lexeme.token {
          RParen
          | Ques
          | Plus
          | Star
          | EscNo
          | Esc
          | LParen
          | LBrack
          | Dot
          | Or => { // reduce
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
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 47
              47 | 81 | 89 | 90 | 112 => 84
              49 => 81
              83 => 90
              88 => 89
              92 => 95
              95 | 120 | 121 => 115
              97 => 112
              114 => 121
              119 => 120
              _ => break
            }
          }
          _ => break
        }
    }
    79 => {
      self.enter_state(79)
      continue match lexeme.token {
          RBrack | EscNo | Esc => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Range(x1)
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x0)
            let node = Array::snoc(x0, x1) |> Node::Array_LB_Range_RB_
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              50 => 58
              59 => 77
              98 => 106
              107 => 109
              _ => break
            }
          }
          _ => break
        }
    }
    80 => {
      self.enter_state(80)
      continue match lexeme.token {
          RParen
          | Ques
          | Plus
          | Star
          | EscNo
          | Esc
          | LParen
          | LBrack
          | Dot
          | Or => { // reduce
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
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 47
              47 | 81 | 89 | 90 | 112 => 84
              49 => 81
              83 => 90
              88 => 89
              92 => 95
              95 | 120 | 121 => 115
              97 => 112
              114 => 121
              119 => 120
              _ => break
            }
          }
          _ => break
        }
    }
    81 => {
      self.enter_state(81)
      continue match lexeme.token {
          RParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            82
          }
          Or => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            83
          }
          Star => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            85
          }
          Plus => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            86
          }
          Ques => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            87
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            49
          }
          LBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan25()
            50
          }
          Dot => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            51
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            52
          }
          Esc => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan23()
            53
          }
          _ => break
        }
    }
    82 => {
      self.enter_state(82)
      continue match lexeme.token {
          RParen
          | Ques
          | Plus
          | Star
          | EscNo
          | Esc
          | LParen
          | LBrack
          | Dot
          | Or => { // reduce
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
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 47
              47 | 81 | 89 | 90 | 112 => 84
              49 => 81
              83 => 90
              88 => 89
              92 => 95
              95 | 120 | 121 => 115
              97 => 112
              114 => 121
              119 => 120
              _ => break
            }
          }
          _ => break
        }
    }
    83 => {
      self.enter_state(83)
      continue match lexeme.token {
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            49
          }
          LBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan25()
            50
          }
          Dot => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            51
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            52
          }
          Esc => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan23()
            53
          }
          _ => break
        }
    }
    84 => {
      self.enter_state(84)
      continue match lexeme.token {
          Star => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            85
          }
          Plus => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            86
          }
          Ques => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            87
          }
          RParen | EscNo | Esc | LParen | LBrack | Dot | Or => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Seq(x0, x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 47
              47 | 81 | 89 | 90 | 112 => 84
              49 => 81
              83 => 90
              88 => 89
              92 => 95
              95 | 120 | 121 => 115
              97 => 112
              114 => 121
              119 => 120
              _ => break
            }
          }
          _ => break
        }
    }
    85 => {
      self.enter_state(85)
      continue match lexeme.token {
          RParen
          | Ques
          | Plus
          | Star
          | EscNo
          | Esc
          | LParen
          | LBrack
          | Dot
          | Or => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 47
              47 | 81 | 89 | 90 | 112 => 84
              49 => 81
              83 => 90
              88 => 89
              92 => 95
              95 | 120 | 121 => 115
              97 => 112
              114 => 121
              119 => 120
              _ => break
            }
          }
          _ => break
        }
    }
    86 => {
      self.enter_state(86)
      continue match lexeme.token {
          RParen
          | Ques
          | Plus
          | Star
          | EscNo
          | Esc
          | LParen
          | LBrack
          | Dot
          | Or => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 47
              47 | 81 | 89 | 90 | 112 => 84
              49 => 81
              83 => 90
              88 => 89
              92 => 95
              95 | 120 | 121 => 115
              97 => 112
              114 => 121
              119 => 120
              _ => break
            }
          }
          _ => break
        }
    }
    87 => {
      self.enter_state(87)
      continue match lexeme.token {
          RParen
          | Ques
          | Plus
          | Star
          | EscNo
          | Esc
          | LParen
          | LBrack
          | Dot
          | Or => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 47
              47 | 81 | 89 | 90 | 112 => 84
              49 => 81
              83 => 90
              88 => 89
              92 => 95
              95 | 120 | 121 => 115
              97 => 112
              114 => 121
              119 => 120
              _ => break
            }
          }
          _ => break
        }
    }
    88 => {
      self.enter_state(88)
      continue match lexeme.token {
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            49
          }
          LBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan25()
            50
          }
          Dot => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            51
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            52
          }
          Esc => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan23()
            53
          }
          _ => break
        }
    }
    89 => {
      self.enter_state(89)
      continue match lexeme.token {
          Or => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            83
          }
          Star => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            85
          }
          Plus => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            86
          }
          Ques => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            87
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            49
          }
          LBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan25()
            50
          }
          Dot => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            51
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            52
          }
          Esc => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan23()
            53
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
            guard self.node_stack.unsafe_pop() is Node::RegExp(x2)
            // ignore Node [x1 : Or]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Union(x0, x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 47
              47 | 81 | 89 | 90 | 112 => 84
              49 => 81
              83 => 90
              88 => 89
              92 => 95
              95 | 120 | 121 => 115
              97 => 112
              114 => 121
              119 => 120
              _ => break
            }
          }
          _ => break
        }
    }
    90 => {
      self.enter_state(90)
      continue match lexeme.token {
          Star => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            85
          }
          Plus => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            86
          }
          Ques => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            87
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            49
          }
          LBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan25()
            50
          }
          Dot => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            51
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            52
          }
          Esc => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan23()
            53
          }
          RParen | Or => { // reduce
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
            guard self.node_stack.unsafe_pop() is Node::RegExp(x2)
            // ignore Node [x1 : Or]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Union(x0, x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 47
              47 | 81 | 89 | 90 | 112 => 84
              49 => 81
              83 => 90
              88 => 89
              92 => 95
              95 | 120 | 121 => 115
              97 => 112
              114 => 121
              119 => 120
              _ => break
            }
          }
          _ => break
        }
    }
    91 => {
      self.enter_state(91)
      continue match lexeme.token {
          LAURUS_EOF | SortName | TokenName | Percent | CommentHead => { // reduce
            let span = self.span_stack[self.span_stack.length() - 7:].iter()
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
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x6 : RParen]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x5)
            // ignore Node [x4 : LParen]
            guard self.node_stack.unsafe_pop() is Node::TokenConv(x3)
            // ignore Node [x2 : Eq]
            guard self.node_stack.unsafe_pop() is Node::String(x1)
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::add_token(x0, x1, x3, x5) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          _ => break
        }
    }
    92 => {
      self.enter_state(92)
      continue match lexeme.token {
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            97
          }
          LBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan25()
            98
          }
          Dot => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            99
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            100
          }
          Esc => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan23()
            101
          }
          _ => break
        }
    }
    93 => {
      self.enter_state(93)
      continue match lexeme.token {
          SortName => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan0()
            94
          }
          _ => break
        }
    }
    94 => {
      self.enter_state(94)
      continue match lexeme.token {
          LAURUS_EOF | SortName | TokenName | Percent | CommentHead => { // reduce
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
            guard self.node_stack.unsafe_pop() is Node::String(x3)
            // ignore Node [x2 : Start]
            // ignore Node [x1 : Percent]
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::set_start(x0, x3) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          _ => break
        }
    }
    95 => {
      self.enter_state(95)
      continue match lexeme.token {
          Or => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            114
          }
          Star => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            116
          }
          Plus => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            117
          }
          Ques => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            118
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            97
          }
          LBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan25()
            98
          }
          Dot => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            99
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            100
          }
          Esc => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan23()
            101
          }
          LAURUS_EOF | SortName | TokenName | Percent | CommentHead => { // reduce
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
            guard self.node_stack.unsafe_pop() is Node::RegExp(x3)
            // ignore Node [x2 : Space]
            // ignore Node [x1 : Percent]
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::set_space(x0, x3) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          _ => break
        }
    }
    96 => {
      self.enter_state(96)
      continue match lexeme.token {
          CommentHead
          | Ques
          | Plus
          | Star
          | EscNo
          | Esc
          | LParen
          | LBrack
          | Dot
          | Or
          | Percent
          | TokenName
          | SortName
          | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 47
              47 | 81 | 89 | 90 | 112 => 84
              49 => 81
              83 => 90
              88 => 89
              92 => 95
              95 | 120 | 121 => 115
              97 => 112
              114 => 121
              119 => 120
              _ => break
            }
          }
          _ => break
        }
    }
    97 => {
      self.enter_state(97)
      continue match lexeme.token {
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            49
          }
          LBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan25()
            50
          }
          Dot => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            51
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            52
          }
          Esc => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan23()
            53
          }
          _ => break
        }
    }
    98 => {
      self.enter_state(98)
      continue match lexeme.token {
          Caret => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan27()
            107
          }
          RBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            108
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan26()
            63
          }
          Esc => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan23()
            64
          }
          _ => break
        }
    }
    99 => {
      self.enter_state(99)
      continue match lexeme.token {
          CommentHead
          | Ques
          | Plus
          | Star
          | EscNo
          | Esc
          | LParen
          | LBrack
          | Dot
          | Or
          | Percent
          | TokenName
          | SortName
          | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 47
              47 | 81 | 89 | 90 | 112 => 84
              49 => 81
              83 => 90
              88 => 89
              92 => 95
              95 | 120 | 121 => 115
              97 => 112
              114 => 121
              119 => 120
              _ => break
            }
          }
          _ => break
        }
    }
    100 => {
      self.enter_state(100)
      continue match lexeme.token {
          CommentHead
          | Ques
          | Plus
          | Star
          | Dot
          | LBrack
          | LParen
          | Esc
          | EscNo
          | Or
          | Percent
          | TokenName
          | SortName
          | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 | 47 | 49 | 81 | 83 | 88 | 89 | 90 | 97 | 112 => 48
              50 | 58 | 59 | 77 | 98 | 106 | 107 | 109 => 62
              69 => 70
              92 | 95 | 114 | 119 | 120 | 121 => 96
              _ => break
            }
          }
          _ => break
        }
    }
    101 => {
      self.enter_state(101)
      continue match lexeme.token {
          EscOrigin => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            102
          }
          EscSpace => { // shift
            let node = self.lexer.get(lexeme) |> Char::esc_space |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            103
          }
          EscU => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan28()
            104
          }
          _ => break
        }
    }
    102 => {
      self.enter_state(102)
      continue match lexeme.token {
          CommentHead
          | Ques
          | Plus
          | Star
          | Dot
          | LBrack
          | LParen
          | Esc
          | EscNo
          | Or
          | Percent
          | TokenName
          | SortName
          | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 | 47 | 49 | 81 | 83 | 88 | 89 | 90 | 97 | 112 => 48
              50 | 58 | 59 | 77 | 98 | 106 | 107 | 109 => 62
              69 => 70
              92 | 95 | 114 | 119 | 120 | 121 => 96
              _ => break
            }
          }
          _ => break
        }
    }
    103 => {
      self.enter_state(103)
      continue match lexeme.token {
          CommentHead
          | Ques
          | Plus
          | Star
          | Dot
          | LBrack
          | LParen
          | Esc
          | EscNo
          | Or
          | Percent
          | TokenName
          | SortName
          | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 | 47 | 49 | 81 | 83 | 88 | 89 | 90 | 97 | 112 => 48
              50 | 58 | 59 | 77 | 98 | 106 | 107 | 109 => 62
              69 => 70
              92 | 95 | 114 | 119 | 120 | 121 => 96
              _ => break
            }
          }
          _ => break
        }
    }
    104 => {
      self.enter_state(104)
      continue match lexeme.token {
          EscUnicode => { // shift
            let node = self.lexer.get(lexeme) |> Char::esc_unicode |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            105
          }
          _ => break
        }
    }
    105 => {
      self.enter_state(105)
      continue match lexeme.token {
          CommentHead
          | Ques
          | Plus
          | Star
          | Dot
          | LBrack
          | LParen
          | Esc
          | EscNo
          | Or
          | Percent
          | TokenName
          | SortName
          | LAURUS_EOF => { // reduce
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
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 | 47 | 49 | 81 | 83 | 88 | 89 | 90 | 97 | 112 => 48
              50 | 58 | 59 | 77 | 98 | 106 | 107 | 109 => 62
              69 => 70
              92 | 95 | 114 | 119 | 120 | 121 => 96
              _ => break
            }
          }
          _ => break
        }
    }
    106 => {
      self.enter_state(106)
      continue match lexeme.token {
          RBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            111
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan26()
            63
          }
          Esc => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan23()
            64
          }
          _ => break
        }
    }
    107 => {
      self.enter_state(107)
      continue match lexeme.token {
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan26()
            63
          }
          Esc => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan23()
            64
          }
          _ => break
        }
    }
    108 => {
      self.enter_state(108)
      continue match lexeme.token {
          CommentHead
          | Ques
          | Plus
          | Star
          | EscNo
          | Esc
          | LParen
          | LBrack
          | Dot
          | Or
          | Percent
          | TokenName
          | SortName
          | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 47
              47 | 81 | 89 | 90 | 112 => 84
              49 => 81
              83 => 90
              88 => 89
              92 => 95
              95 | 120 | 121 => 115
              97 => 112
              114 => 121
              119 => 120
              _ => break
            }
          }
          _ => break
        }
    }
    109 => {
      self.enter_state(109)
      continue match lexeme.token {
          RBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            110
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan26()
            63
          }
          Esc => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan23()
            64
          }
          _ => break
        }
    }
    110 => {
      self.enter_state(110)
      continue match lexeme.token {
          CommentHead
          | Ques
          | Plus
          | Star
          | EscNo
          | Esc
          | LParen
          | LBrack
          | Dot
          | Or
          | Percent
          | TokenName
          | SortName
          | LAURUS_EOF => { // reduce
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
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 47
              47 | 81 | 89 | 90 | 112 => 84
              49 => 81
              83 => 90
              88 => 89
              92 => 95
              95 | 120 | 121 => 115
              97 => 112
              114 => 121
              119 => 120
              _ => break
            }
          }
          _ => break
        }
    }
    111 => {
      self.enter_state(111)
      continue match lexeme.token {
          CommentHead
          | Ques
          | Plus
          | Star
          | EscNo
          | Esc
          | LParen
          | LBrack
          | Dot
          | Or
          | Percent
          | TokenName
          | SortName
          | LAURUS_EOF => { // reduce
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
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 47
              47 | 81 | 89 | 90 | 112 => 84
              49 => 81
              83 => 90
              88 => 89
              92 => 95
              95 | 120 | 121 => 115
              97 => 112
              114 => 121
              119 => 120
              _ => break
            }
          }
          _ => break
        }
    }
    112 => {
      self.enter_state(112)
      continue match lexeme.token {
          RParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            113
          }
          Or => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            83
          }
          Star => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            85
          }
          Plus => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            86
          }
          Ques => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            87
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            49
          }
          LBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan25()
            50
          }
          Dot => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            51
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan24()
            52
          }
          Esc => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan23()
            53
          }
          _ => break
        }
    }
    113 => {
      self.enter_state(113)
      continue match lexeme.token {
          CommentHead
          | Ques
          | Plus
          | Star
          | EscNo
          | Esc
          | LParen
          | LBrack
          | Dot
          | Or
          | Percent
          | TokenName
          | SortName
          | LAURUS_EOF => { // reduce
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
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 47
              47 | 81 | 89 | 90 | 112 => 84
              49 => 81
              83 => 90
              88 => 89
              92 => 95
              95 | 120 | 121 => 115
              97 => 112
              114 => 121
              119 => 120
              _ => break
            }
          }
          _ => break
        }
    }
    114 => {
      self.enter_state(114)
      continue match lexeme.token {
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            97
          }
          LBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan25()
            98
          }
          Dot => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            99
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            100
          }
          Esc => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan23()
            101
          }
          _ => break
        }
    }
    115 => {
      self.enter_state(115)
      continue match lexeme.token {
          Star => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            116
          }
          Plus => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            117
          }
          Ques => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            118
          }
          CommentHead
          | EscNo
          | Esc
          | LParen
          | LBrack
          | Dot
          | Or
          | Percent
          | TokenName
          | SortName
          | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Seq(x0, x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 47
              47 | 81 | 89 | 90 | 112 => 84
              49 => 81
              83 => 90
              88 => 89
              92 => 95
              95 | 120 | 121 => 115
              97 => 112
              114 => 121
              119 => 120
              _ => break
            }
          }
          _ => break
        }
    }
    116 => {
      self.enter_state(116)
      continue match lexeme.token {
          CommentHead
          | Ques
          | Plus
          | Star
          | EscNo
          | Esc
          | LParen
          | LBrack
          | Dot
          | Or
          | Percent
          | TokenName
          | SortName
          | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 47
              47 | 81 | 89 | 90 | 112 => 84
              49 => 81
              83 => 90
              88 => 89
              92 => 95
              95 | 120 | 121 => 115
              97 => 112
              114 => 121
              119 => 120
              _ => break
            }
          }
          _ => break
        }
    }
    117 => {
      self.enter_state(117)
      continue match lexeme.token {
          CommentHead
          | Ques
          | Plus
          | Star
          | EscNo
          | Esc
          | LParen
          | LBrack
          | Dot
          | Or
          | Percent
          | TokenName
          | SortName
          | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 47
              47 | 81 | 89 | 90 | 112 => 84
              49 => 81
              83 => 90
              88 => 89
              92 => 95
              95 | 120 | 121 => 115
              97 => 112
              114 => 121
              119 => 120
              _ => break
            }
          }
          _ => break
        }
    }
    118 => {
      self.enter_state(118)
      continue match lexeme.token {
          CommentHead
          | Ques
          | Plus
          | Star
          | EscNo
          | Esc
          | LParen
          | LBrack
          | Dot
          | Or
          | Percent
          | TokenName
          | SortName
          | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 47
              47 | 81 | 89 | 90 | 112 => 84
              49 => 81
              83 => 90
              88 => 89
              92 => 95
              95 | 120 | 121 => 115
              97 => 112
              114 => 121
              119 => 120
              _ => break
            }
          }
          _ => break
        }
    }
    119 => {
      self.enter_state(119)
      continue match lexeme.token {
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            97
          }
          LBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan25()
            98
          }
          Dot => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            99
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            100
          }
          Esc => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan23()
            101
          }
          _ => break
        }
    }
    120 => {
      self.enter_state(120)
      continue match lexeme.token {
          Or => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            114
          }
          Star => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            116
          }
          Plus => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            117
          }
          Ques => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            118
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            97
          }
          LBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan25()
            98
          }
          Dot => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            99
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            100
          }
          Esc => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan23()
            101
          }
          LAURUS_EOF | SortName | TokenName | Percent | CommentHead => { // reduce
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
            guard self.node_stack.unsafe_pop() is Node::RegExp(x2)
            // ignore Node [x1 : Or]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Union(x0, x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 47
              47 | 81 | 89 | 90 | 112 => 84
              49 => 81
              83 => 90
              88 => 89
              92 => 95
              95 | 120 | 121 => 115
              97 => 112
              114 => 121
              119 => 120
              _ => break
            }
          }
          _ => break
        }
    }
    121 => {
      self.enter_state(121)
      continue match lexeme.token {
          Star => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            116
          }
          Plus => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            117
          }
          Ques => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            118
          }
          LParen => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan6()
            97
          }
          LBrack => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan25()
            98
          }
          Dot => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            99
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan30()
            100
          }
          Esc => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan23()
            101
          }
          CommentHead | Or | Percent | TokenName | SortName | LAURUS_EOF => { // reduce
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
            guard self.node_stack.unsafe_pop() is Node::RegExp(x2)
            // ignore Node [x1 : Or]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Union(x0, x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 47
              47 | 81 | 89 | 90 | 112 => 84
              49 => 81
              83 => 90
              88 => 89
              92 => 95
              95 | 120 | 121 => 115
              97 => 112
              114 => 121
              119 => 120
              _ => break
            }
          }
          _ => break
        }
    }
    122 => {
      self.enter_state(122)
      continue match lexeme.token {
          LAURUS_EOF | SortName | TokenName | Percent | CommentHead => { // reduce
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
            guard self.node_stack.unsafe_pop() is Node::String(x2)
            // ignore Node [x1 : CommentHead]
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::add_comment(x0, x2) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          _ => break
        }
    }
    _ => break
  }
  match self.node_stack[0] {
    Laurus(node) => Some(node)
    _ => None
  }
}
