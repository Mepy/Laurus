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
          LAURUS_EOF => { // reduce
            let node = Laurus::new() |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          SortName => { // reduce
            let node = Laurus::new() |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          TokenName => { // reduce
            let node = Laurus::new() |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          Percent => { // reduce
            let node = Laurus::new() |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          CommentHead => { // reduce
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
            lexeme = self.lexer.scan4()
            2
          }
          Percent => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan3()
            3
          }
          TokenName => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            lexeme = self.lexer.scan2()
            4
          }
          SortName => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            lexeme = self.lexer.scan1()
            5
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
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
            lexeme = self.lexer.scan0()
            116
          }
          _ => break
        }
    }
    3 => {
      self.enter_state(3)
      continue match lexeme.token {
          Space => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            112
          }
          Start => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan5()
            113
          }
          _ => break
        }
    }
    4 => {
      self.enter_state(4)
      continue match lexeme.token {
          Eq => { // shift
            // ignore the old lexeme
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
            lexeme = self.lexer.scan8()
            7
          }
          LBrace => { // reduce
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
            lexeme = self.lexer.scan8()
            9
          }
          LBrace => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
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
            lexeme = self.lexer.scan8()
            12
          }
          RBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
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
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
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
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
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
          RBrace => { // reduce
            let node = Array::empty() |> Node::Array_LB_Rule_RB_
            self.node_stack.push(node)
            17
          }
          Eq => { // reduce
            let node = Array::empty() |> Node::Array_LB_Rule_RB_
            self.node_stack.push(node)
            17
          }
          Or => { // reduce
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
            lexeme = self.lexer.scan0()
            18
          }
          Eq => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan14()
            21
          }
          Or => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan14()
            22
          }
          _ => break
        }
    }
    18 => {
      self.enter_state(18)
      continue match lexeme.token {
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
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
          SortName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
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
          TokenName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
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
          Percent => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
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
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
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
          RBrace => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Rule(x1)
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Rule_RB_(x0)
            let node = Array::snoc(x0, x1) |> Node::Array_LB_Rule_RB_
            self.node_stack.push(node)
            17
          }
          Eq => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Rule(x1)
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Rule_RB_(x0)
            let node = Array::snoc(x0, x1) |> Node::Array_LB_Rule_RB_
            self.node_stack.push(node)
            17
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
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
            lexeme = self.lexer.scan15()
            24
          }
          Shift => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan15()
            25
          }
          ConstructorName => { // reduce
            let node = ShiftReduce::Reduce |> Node::ShiftReduce
            self.node_stack.push(node)
            23
          }
          MethodName => { // reduce
            let node = ShiftReduce::Reduce |> Node::ShiftReduce
            self.node_stack.push(node)
            23
          }
          LParen => { // reduce
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
          Reduce => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Eq]
            let node = Priority::Equal |> Node::Priority
            self.node_stack.push(node)
            20
          }
          Shift => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Eq]
            let node = Priority::Equal |> Node::Priority
            self.node_stack.push(node)
            20
          }
          ConstructorName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Eq]
            let node = Priority::Equal |> Node::Priority
            self.node_stack.push(node)
            20
          }
          MethodName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Eq]
            let node = Priority::Equal |> Node::Priority
            self.node_stack.push(node)
            20
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Eq]
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
          Reduce => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Or]
            let node = Priority::Higher |> Node::Priority
            self.node_stack.push(node)
            20
          }
          Shift => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Or]
            let node = Priority::Higher |> Node::Priority
            self.node_stack.push(node)
            20
          }
          ConstructorName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Or]
            let node = Priority::Higher |> Node::Priority
            self.node_stack.push(node)
            20
          }
          MethodName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Or]
            let node = Priority::Higher |> Node::Priority
            self.node_stack.push(node)
            20
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Or]
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
            lexeme = self.lexer.scan16()
            27
          }
          MethodName => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            lexeme = self.lexer.scan16()
            28
          }
          LParen => { // reduce
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
          ConstructorName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Reduce]
            let node = ShiftReduce::Reduce |> Node::ShiftReduce
            self.node_stack.push(node)
            23
          }
          MethodName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Reduce]
            let node = ShiftReduce::Reduce |> Node::ShiftReduce
            self.node_stack.push(node)
            23
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
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
          ConstructorName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Shift]
            let node = ShiftReduce::Shift |> Node::ShiftReduce
            self.node_stack.push(node)
            23
          }
          MethodName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Shift]
            let node = ShiftReduce::Shift |> Node::ShiftReduce
            self.node_stack.push(node)
            23
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
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
            self.state_stack.unsafe_pop() |> ignore
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
            self.state_stack.unsafe_pop() |> ignore
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
          RParen => { // reduce
            let node = Array::empty() |> Node::Array_LB_Symbol_RB_
            self.node_stack.push(node)
            30
          }
          Symbol => { // reduce
            let node = Array::empty() |> Node::Array_LB_Symbol_RB_
            self.node_stack.push(node)
            30
          }
          LBrack => { // reduce
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
            lexeme = self.lexer.scan9()
            31
          }
          Symbol => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            lexeme = self.lexer.scan17()
            33
          }
          LBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan18()
            34
          }
          _ => break
        }
    }
    31 => {
      self.enter_state(31)
      continue match lexeme.token {
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
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
          Eq => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
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
          RBrace => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
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
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Symbol(x1)
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Symbol_RB_(x0)
            let node = Array::snoc(x0, x1) |> Node::Array_LB_Symbol_RB_
            self.node_stack.push(node)
            30
          }
          Symbol => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Symbol(x1)
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Symbol_RB_(x0)
            let node = Array::snoc(x0, x1) |> Node::Array_LB_Symbol_RB_
            self.node_stack.push(node)
            30
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
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
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = Symbol::Unnamed(x0) |> Node::Symbol
            self.node_stack.push(node)
            32
          }
          Symbol => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = Symbol::Unnamed(x0) |> Node::Symbol
            self.node_stack.push(node)
            32
          }
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
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
            lexeme = self.lexer.scan20()
            36
          }
          Tilde => { // shift
            // ignore the old lexeme
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
            lexeme = self.lexer.scan17()
            38
          }
          _ => break
        }
    }
    38 => {
      self.enter_state(38)
      continue match lexeme.token {
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            // ignore Node [x2 : Tilde]
            guard self.node_stack.unsafe_pop() is Node::String(x1)
            // ignore Node [x0 : LBrack]
            let node = Symbol::NamedAbbrev(field_name=x1) |> Node::Symbol
            self.node_stack.push(node)
            32
          }
          Symbol => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            // ignore Node [x2 : Tilde]
            guard self.node_stack.unsafe_pop() is Node::String(x1)
            // ignore Node [x0 : LBrack]
            let node = Symbol::NamedAbbrev(field_name=x1) |> Node::Symbol
            self.node_stack.push(node)
            32
          }
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
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
            lexeme = self.lexer.scan17()
            40
          }
          _ => break
        }
    }
    40 => {
      self.enter_state(40)
      continue match lexeme.token {
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x4 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::String(x3)
            // ignore Node [x2 : Colon]
            guard self.node_stack.unsafe_pop() is Node::String(x1)
            // ignore Node [x0 : LBrack]
            let node = Symbol::Named(field_name=x1, x3) |> Node::Symbol
            self.node_stack.push(node)
            32
          }
          Symbol => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x4 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::String(x3)
            // ignore Node [x2 : Colon]
            guard self.node_stack.unsafe_pop() is Node::String(x1)
            // ignore Node [x0 : LBrack]
            let node = Symbol::Named(field_name=x1, x3) |> Node::Symbol
            self.node_stack.push(node)
            32
          }
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
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
            lexeme = self.lexer.scan21()
            43
          }
          EscNo => { // reduce
            let node = TokenConv::Ignore |> Node::TokenConv
            self.node_stack.push(node)
            42
          }
          Esc => { // reduce
            let node = TokenConv::Ignore |> Node::TokenConv
            self.node_stack.push(node)
            42
          }
          LParen => { // reduce
            let node = TokenConv::Ignore |> Node::TokenConv
            self.node_stack.push(node)
            42
          }
          LBrack => { // reduce
            let node = TokenConv::Ignore |> Node::TokenConv
            self.node_stack.push(node)
            42
          }
          Dot => { // reduce
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
            lexeme = self.lexer.scan6()
            47
          }
          LBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan24()
            48
          }
          Dot => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan23()
            49
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan23()
            51
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            52
          }
          _ => break
        }
    }
    43 => {
      self.enter_state(43)
      continue match lexeme.token {
          ColonColon => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan25()
            44
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::BuiltIn(x0) |> Node::TokenConv
            self.node_stack.push(node)
            42
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::BuiltIn(x0) |> Node::TokenConv
            self.node_stack.push(node)
            42
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::BuiltIn(x0) |> Node::TokenConv
            self.node_stack.push(node)
            42
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::BuiltIn(x0) |> Node::TokenConv
            self.node_stack.push(node)
            42
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
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
            lexeme = self.lexer.scan6()
            45
          }
          _ => break
        }
    }
    45 => {
      self.enter_state(45)
      continue match lexeme.token {
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x2)
            // ignore Node [x1 : ColonColon]
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::Interpret(type_name=x0, parse_func_name=x2)
              |> Node::TokenConv
            self.node_stack.push(node)
            42
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x2)
            // ignore Node [x1 : ColonColon]
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::Interpret(type_name=x0, parse_func_name=x2)
              |> Node::TokenConv
            self.node_stack.push(node)
            42
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x2)
            // ignore Node [x1 : ColonColon]
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::Interpret(type_name=x0, parse_func_name=x2)
              |> Node::TokenConv
            self.node_stack.push(node)
            42
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x2)
            // ignore Node [x1 : ColonColon]
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::Interpret(type_name=x0, parse_func_name=x2)
              |> Node::TokenConv
            self.node_stack.push(node)
            42
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
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
          Or => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            106
          }
          Star => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan23()
            108
          }
          Plus => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan23()
            109
          }
          Ques => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan23()
            110
          }
          LParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            47
          }
          LBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan24()
            48
          }
          Dot => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan23()
            49
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan23()
            51
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            52
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x4)
            guard self.node_stack.unsafe_pop() is Node::TokenConv(x3)
            // ignore Node [x2 : Eq]
            guard self.node_stack.unsafe_pop() is Node::String(x1)
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::add_token(x0, x1, x3, x4) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          SortName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x4)
            guard self.node_stack.unsafe_pop() is Node::TokenConv(x3)
            // ignore Node [x2 : Eq]
            guard self.node_stack.unsafe_pop() is Node::String(x1)
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::add_token(x0, x1, x3, x4) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          TokenName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x4)
            guard self.node_stack.unsafe_pop() is Node::TokenConv(x3)
            // ignore Node [x2 : Eq]
            guard self.node_stack.unsafe_pop() is Node::String(x1)
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::add_token(x0, x1, x3, x4) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          Percent => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x4)
            guard self.node_stack.unsafe_pop() is Node::TokenConv(x3)
            // ignore Node [x2 : Eq]
            guard self.node_stack.unsafe_pop() is Node::String(x1)
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::add_token(x0, x1, x3, x4) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x4)
            guard self.node_stack.unsafe_pop() is Node::TokenConv(x3)
            // ignore Node [x2 : Eq]
            guard self.node_stack.unsafe_pop() is Node::String(x1)
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::add_token(x0, x1, x3, x4) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          _ => break
        }
    }
    47 => {
      self.enter_state(47)
      continue match lexeme.token {
          LParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            81
          }
          LBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan24()
            82
          }
          Dot => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan26()
            83
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan26()
            85
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            86
          }
          _ => break
        }
    }
    48 => {
      self.enter_state(48)
      continue match lexeme.token {
          Caret => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan28()
            58
          }
          RBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan23()
            59
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan27()
            62
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            63
          }
          _ => break
        }
    }
    49 => {
      self.enter_state(49)
      continue match lexeme.token {
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Percent => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          TokenName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          SortName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          _ => break
        }
    }
    50 => {
      self.enter_state(50)
      continue match lexeme.token {
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Percent => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          TokenName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          SortName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          _ => break
        }
    }
    51 => {
      self.enter_state(51)
      continue match lexeme.token {
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Percent => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          TokenName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          SortName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          _ => break
        }
    }
    52 => {
      self.enter_state(52)
      continue match lexeme.token {
          EscOrigin => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan23()
            53
          }
          EscSpace => { // shift
            let node = self.lexer.get(lexeme) |> Char::esc_space |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan23()
            54
          }
          EscU => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan29()
            55
          }
          _ => break
        }
    }
    53 => {
      self.enter_state(53)
      continue match lexeme.token {
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Percent => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          TokenName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          SortName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          _ => break
        }
    }
    54 => {
      self.enter_state(54)
      continue match lexeme.token {
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Percent => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          TokenName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          SortName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          _ => break
        }
    }
    55 => {
      self.enter_state(55)
      continue match lexeme.token {
          EscUnicode => { // shift
            let node = self.lexer.get(lexeme) |> Char::esc_unicode |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan23()
            56
          }
          _ => break
        }
    }
    56 => {
      self.enter_state(56)
      continue match lexeme.token {
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Percent => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          TokenName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          SortName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          _ => break
        }
    }
    57 => {
      self.enter_state(57)
      continue match lexeme.token {
          RBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan23()
            79
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan27()
            62
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            63
          }
          _ => break
        }
    }
    58 => {
      self.enter_state(58)
      continue match lexeme.token {
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan27()
            62
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            63
          }
          _ => break
        }
    }
    59 => {
      self.enter_state(59)
      continue match lexeme.token {
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Percent => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          TokenName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          SortName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          _ => break
        }
    }
    60 => {
      self.enter_state(60)
      continue match lexeme.token {
          RBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Range(x0)
            let node = Array::singleton(x0) |> Node::Array_LB_Range_RB_
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              48 => 57
              58 => 76
              82 => 91
              92 => 94
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Range(x0)
            let node = Array::singleton(x0) |> Node::Array_LB_Range_RB_
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              48 => 57
              58 => 76
              82 => 91
              92 => 94
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Range(x0)
            let node = Array::singleton(x0) |> Node::Array_LB_Range_RB_
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              48 => 57
              58 => 76
              82 => 91
              92 => 94
              _ => break
            }
          }
          _ => break
        }
    }
    61 => {
      self.enter_state(61)
      continue match lexeme.token {
          Dash => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan28()
            68
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = Range::single(x0) |> Node::Range
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              48 => 60
              57 => 78
              58 => 60
              76 => 78
              82 => 60
              91 => 78
              92 => 60
              94 => 78
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = Range::single(x0) |> Node::Range
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              48 => 60
              57 => 78
              58 => 60
              76 => 78
              82 => 60
              91 => 78
              92 => 60
              94 => 78
              _ => break
            }
          }
          RBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = Range::single(x0) |> Node::Range
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              48 => 60
              57 => 78
              58 => 60
              76 => 78
              82 => 60
              91 => 78
              92 => 60
              94 => 78
              _ => break
            }
          }
          _ => break
        }
    }
    62 => {
      self.enter_state(62)
      continue match lexeme.token {
          Dash => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          RBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          _ => break
        }
    }
    63 => {
      self.enter_state(63)
      continue match lexeme.token {
          EscOrigin => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan27()
            64
          }
          EscSpace => { // shift
            let node = self.lexer.get(lexeme) |> Char::esc_space |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan27()
            65
          }
          EscU => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan29()
            66
          }
          _ => break
        }
    }
    64 => {
      self.enter_state(64)
      continue match lexeme.token {
          Dash => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          RBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          _ => break
        }
    }
    65 => {
      self.enter_state(65)
      continue match lexeme.token {
          Dash => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          RBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          _ => break
        }
    }
    66 => {
      self.enter_state(66)
      continue match lexeme.token {
          EscUnicode => { // shift
            let node = self.lexer.get(lexeme) |> Char::esc_unicode |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan27()
            67
          }
          _ => break
        }
    }
    67 => {
      self.enter_state(67)
      continue match lexeme.token {
          Dash => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          RBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          _ => break
        }
    }
    68 => {
      self.enter_state(68)
      continue match lexeme.token {
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan30()
            70
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            71
          }
          _ => break
        }
    }
    69 => {
      self.enter_state(69)
      continue match lexeme.token {
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : Dash]
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = Range(x0, x2) |> Node::Range
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              48 => 60
              57 => 78
              58 => 60
              76 => 78
              82 => 60
              91 => 78
              92 => 60
              94 => 78
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : Dash]
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = Range(x0, x2) |> Node::Range
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              48 => 60
              57 => 78
              58 => 60
              76 => 78
              82 => 60
              91 => 78
              92 => 60
              94 => 78
              _ => break
            }
          }
          RBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : Dash]
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = Range(x0, x2) |> Node::Range
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              48 => 60
              57 => 78
              58 => 60
              76 => 78
              82 => 60
              91 => 78
              92 => 60
              94 => 78
              _ => break
            }
          }
          _ => break
        }
    }
    70 => {
      self.enter_state(70)
      continue match lexeme.token {
          RBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          _ => break
        }
    }
    71 => {
      self.enter_state(71)
      continue match lexeme.token {
          EscOrigin => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan30()
            72
          }
          EscSpace => { // shift
            let node = self.lexer.get(lexeme) |> Char::esc_space |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan30()
            73
          }
          EscU => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan29()
            74
          }
          _ => break
        }
    }
    72 => {
      self.enter_state(72)
      continue match lexeme.token {
          RBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          _ => break
        }
    }
    73 => {
      self.enter_state(73)
      continue match lexeme.token {
          RBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          _ => break
        }
    }
    74 => {
      self.enter_state(74)
      continue match lexeme.token {
          EscUnicode => { // shift
            let node = self.lexer.get(lexeme) |> Char::esc_unicode |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan30()
            75
          }
          _ => break
        }
    }
    75 => {
      self.enter_state(75)
      continue match lexeme.token {
          RBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          _ => break
        }
    }
    76 => {
      self.enter_state(76)
      continue match lexeme.token {
          RBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan23()
            77
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan27()
            62
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            63
          }
          _ => break
        }
    }
    77 => {
      self.enter_state(77)
      continue match lexeme.token {
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Percent => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          TokenName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          SortName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          _ => break
        }
    }
    78 => {
      self.enter_state(78)
      continue match lexeme.token {
          RBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Range(x1)
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x0)
            let node = Array::snoc(x0, x1) |> Node::Array_LB_Range_RB_
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              48 => 57
              58 => 76
              82 => 91
              92 => 94
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Range(x1)
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x0)
            let node = Array::snoc(x0, x1) |> Node::Array_LB_Range_RB_
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              48 => 57
              58 => 76
              82 => 91
              92 => 94
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Range(x1)
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x0)
            let node = Array::snoc(x0, x1) |> Node::Array_LB_Range_RB_
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              48 => 57
              58 => 76
              82 => 91
              92 => 94
              _ => break
            }
          }
          _ => break
        }
    }
    79 => {
      self.enter_state(79)
      continue match lexeme.token {
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Percent => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          TokenName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          SortName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          _ => break
        }
    }
    80 => {
      self.enter_state(80)
      continue match lexeme.token {
          RParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan23()
            105
          }
          Or => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            99
          }
          Star => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan26()
            101
          }
          Plus => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan26()
            102
          }
          Ques => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan26()
            103
          }
          LParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            81
          }
          LBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan24()
            82
          }
          Dot => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan26()
            83
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan26()
            85
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            86
          }
          _ => break
        }
    }
    81 => {
      self.enter_state(81)
      continue match lexeme.token {
          LParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            81
          }
          LBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan24()
            82
          }
          Dot => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan26()
            83
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan26()
            85
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            86
          }
          _ => break
        }
    }
    82 => {
      self.enter_state(82)
      continue match lexeme.token {
          Caret => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan28()
            92
          }
          RBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan26()
            93
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan27()
            62
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            63
          }
          _ => break
        }
    }
    83 => {
      self.enter_state(83)
      continue match lexeme.token {
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          _ => break
        }
    }
    84 => {
      self.enter_state(84)
      continue match lexeme.token {
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          _ => break
        }
    }
    85 => {
      self.enter_state(85)
      continue match lexeme.token {
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          _ => break
        }
    }
    86 => {
      self.enter_state(86)
      continue match lexeme.token {
          EscOrigin => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan26()
            87
          }
          EscSpace => { // shift
            let node = self.lexer.get(lexeme) |> Char::esc_space |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan26()
            88
          }
          EscU => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan29()
            89
          }
          _ => break
        }
    }
    87 => {
      self.enter_state(87)
      continue match lexeme.token {
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          _ => break
        }
    }
    88 => {
      self.enter_state(88)
      continue match lexeme.token {
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          _ => break
        }
    }
    89 => {
      self.enter_state(89)
      continue match lexeme.token {
          EscUnicode => { // shift
            let node = self.lexer.get(lexeme) |> Char::esc_unicode |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan26()
            90
          }
          _ => break
        }
    }
    90 => {
      self.enter_state(90)
      continue match lexeme.token {
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 50
              46 => 50
              47 => 84
              48 => 61
              57 => 61
              58 => 61
              68 => 69
              76 => 61
              80 => 84
              81 => 84
              82 => 61
              91 => 61
              92 => 61
              94 => 61
              97 => 84
              99 => 84
              100 => 84
              104 => 84
              106 => 50
              107 => 50
              111 => 50
              112 => 50
              115 => 50
              _ => break
            }
          }
          _ => break
        }
    }
    91 => {
      self.enter_state(91)
      continue match lexeme.token {
          RBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan26()
            96
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan27()
            62
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            63
          }
          _ => break
        }
    }
    92 => {
      self.enter_state(92)
      continue match lexeme.token {
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan27()
            62
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            63
          }
          _ => break
        }
    }
    93 => {
      self.enter_state(93)
      continue match lexeme.token {
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : RBrack]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          _ => break
        }
    }
    94 => {
      self.enter_state(94)
      continue match lexeme.token {
          RBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan26()
            95
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan27()
            62
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            63
          }
          _ => break
        }
    }
    95 => {
      self.enter_state(95)
      continue match lexeme.token {
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x3 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x2)
            // ignore Node [x1 : Caret]
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bnot(x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          _ => break
        }
    }
    96 => {
      self.enter_state(96)
      continue match lexeme.token {
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RBrack]
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x1)
            // ignore Node [x0 : LBrack]
            let node = RegExp::Bor(x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          _ => break
        }
    }
    97 => {
      self.enter_state(97)
      continue match lexeme.token {
          RParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan26()
            98
          }
          Or => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            99
          }
          Star => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan26()
            101
          }
          Plus => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan26()
            102
          }
          Ques => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan26()
            103
          }
          LParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            81
          }
          LBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan24()
            82
          }
          Dot => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan26()
            83
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan26()
            85
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            86
          }
          _ => break
        }
    }
    98 => {
      self.enter_state(98)
      continue match lexeme.token {
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          _ => break
        }
    }
    99 => {
      self.enter_state(99)
      continue match lexeme.token {
          LParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            81
          }
          LBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan24()
            82
          }
          Dot => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan26()
            83
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan26()
            85
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            86
          }
          _ => break
        }
    }
    100 => {
      self.enter_state(100)
      continue match lexeme.token {
          Star => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan26()
            101
          }
          Plus => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan26()
            102
          }
          Ques => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan26()
            103
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan26()
            85
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            86
          }
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Seq(x0, x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Seq(x0, x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Seq(x0, x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Seq(x0, x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Seq(x0, x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          _ => break
        }
    }
    101 => {
      self.enter_state(101)
      continue match lexeme.token {
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          _ => break
        }
    }
    102 => {
      self.enter_state(102)
      continue match lexeme.token {
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          _ => break
        }
    }
    103 => {
      self.enter_state(103)
      continue match lexeme.token {
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          _ => break
        }
    }
    104 => {
      self.enter_state(104)
      continue match lexeme.token {
          Star => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan26()
            101
          }
          Plus => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan26()
            102
          }
          Ques => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan26()
            103
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan26()
            85
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            86
          }
          RParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x2)
            // ignore Node [x1 : Or]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Union(x0, x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x2)
            // ignore Node [x1 : Or]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Union(x0, x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x2)
            // ignore Node [x1 : Or]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Union(x0, x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x2)
            // ignore Node [x1 : Or]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Union(x0, x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x2)
            // ignore Node [x1 : Or]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Union(x0, x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          _ => break
        }
    }
    105 => {
      self.enter_state(105)
      continue match lexeme.token {
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Percent => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          TokenName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          SortName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x2 : RParen]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            // ignore Node [x0 : LParen]
            let node = x1 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          _ => break
        }
    }
    106 => {
      self.enter_state(106)
      continue match lexeme.token {
          LParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            47
          }
          LBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan24()
            48
          }
          Dot => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan23()
            49
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan23()
            51
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            52
          }
          _ => break
        }
    }
    107 => {
      self.enter_state(107)
      continue match lexeme.token {
          Star => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan23()
            108
          }
          Plus => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan23()
            109
          }
          Ques => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan23()
            110
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan23()
            51
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            52
          }
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Seq(x0, x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Seq(x0, x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Seq(x0, x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Seq(x0, x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Seq(x0, x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Percent => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Seq(x0, x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          TokenName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Seq(x0, x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          SortName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Seq(x0, x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Seq(x0, x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          _ => break
        }
    }
    108 => {
      self.enter_state(108)
      continue match lexeme.token {
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Percent => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          TokenName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          SortName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          _ => break
        }
    }
    109 => {
      self.enter_state(109)
      continue match lexeme.token {
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Percent => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          TokenName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          SortName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Plus]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Plus(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          _ => break
        }
    }
    110 => {
      self.enter_state(110)
      continue match lexeme.token {
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Percent => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          TokenName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          SortName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x1 : Ques]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Ques(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          _ => break
        }
    }
    111 => {
      self.enter_state(111)
      continue match lexeme.token {
          Star => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan23()
            108
          }
          Plus => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan23()
            109
          }
          Ques => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan23()
            110
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan23()
            51
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            52
          }
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x2)
            // ignore Node [x1 : Or]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Union(x0, x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LParen => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x2)
            // ignore Node [x1 : Or]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Union(x0, x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x2)
            // ignore Node [x1 : Or]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Union(x0, x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x2)
            // ignore Node [x1 : Or]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Union(x0, x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x2)
            // ignore Node [x1 : Or]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Union(x0, x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          Percent => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x2)
            // ignore Node [x1 : Or]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Union(x0, x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          TokenName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x2)
            // ignore Node [x1 : Or]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Union(x0, x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          SortName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x2)
            // ignore Node [x1 : Or]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Union(x0, x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x2)
            // ignore Node [x1 : Or]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Union(x0, x2) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              42 => 46
              46 => 107
              47 => 80
              80 => 100
              81 => 97
              97 => 100
              99 => 104
              100 => 100
              104 => 100
              106 => 111
              107 => 107
              111 => 107
              112 => 115
              115 => 107
              _ => break
            }
          }
          _ => break
        }
    }
    112 => {
      self.enter_state(112)
      continue match lexeme.token {
          LParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            47
          }
          LBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan24()
            48
          }
          Dot => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan23()
            49
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan23()
            51
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            52
          }
          _ => break
        }
    }
    113 => {
      self.enter_state(113)
      continue match lexeme.token {
          SortName => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            lexeme = self.lexer.scan0()
            114
          }
          _ => break
        }
    }
    114 => {
      self.enter_state(114)
      continue match lexeme.token {
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x3)
            // ignore Node [x2 : Start]
            // ignore Node [x1 : Percent]
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::set_start(x0, x3) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          SortName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x3)
            // ignore Node [x2 : Start]
            // ignore Node [x1 : Percent]
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::set_start(x0, x3) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          TokenName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x3)
            // ignore Node [x2 : Start]
            // ignore Node [x1 : Percent]
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::set_start(x0, x3) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          Percent => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x3)
            // ignore Node [x2 : Start]
            // ignore Node [x1 : Percent]
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::set_start(x0, x3) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
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
    115 => {
      self.enter_state(115)
      continue match lexeme.token {
          Or => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            106
          }
          Star => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan23()
            108
          }
          Plus => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan23()
            109
          }
          Ques => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan23()
            110
          }
          LParen => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            47
          }
          LBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan24()
            48
          }
          Dot => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan23()
            49
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan23()
            51
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            52
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x3)
            // ignore Node [x2 : Space]
            // ignore Node [x1 : Percent]
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::set_space(x0, x3) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          SortName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x3)
            // ignore Node [x2 : Space]
            // ignore Node [x1 : Percent]
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::set_space(x0, x3) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          TokenName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x3)
            // ignore Node [x2 : Space]
            // ignore Node [x1 : Percent]
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::set_space(x0, x3) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          Percent => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x3)
            // ignore Node [x2 : Space]
            // ignore Node [x1 : Percent]
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::set_space(x0, x3) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
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
    116 => {
      self.enter_state(116)
      continue match lexeme.token {
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x2)
            // ignore Node [x1 : CommentHead]
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::add_comment(x0, x2) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          SortName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x2)
            // ignore Node [x1 : CommentHead]
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::add_comment(x0, x2) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          TokenName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x2)
            // ignore Node [x1 : CommentHead]
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::add_comment(x0, x2) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          Percent => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x2)
            // ignore Node [x1 : CommentHead]
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::add_comment(x0, x2) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
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
