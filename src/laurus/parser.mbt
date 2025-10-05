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
            87
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
            83
          }
          Start => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan5()
            84
          }
          _ => break
        }
    }
    4 => {
      self.enter_state(4)
      continue match lexeme.token {
          TypeName => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            lexeme = self.lexer.scan7()
            42
          }
          EscNo => { // reduce
            let node = TokenConv::Ignore |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          Esc => { // reduce
            let node = TokenConv::Ignore |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          LBrack => { // reduce
            let node = TokenConv::Ignore |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          Dot => { // reduce
            let node = TokenConv::Ignore |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          Or => { // reduce
            let node = TokenConv::Ignore |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          Star => { // reduce
            let node = TokenConv::Ignore |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          Plus => { // reduce
            let node = TokenConv::Ignore |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          Ques => { // reduce
            let node = TokenConv::Ignore |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          CommentHead => { // reduce
            let node = TokenConv::Ignore |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          Percent => { // reduce
            let node = TokenConv::Ignore |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          TokenName => { // reduce
            let node = TokenConv::Ignore |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          SortName => { // reduce
            let node = TokenConv::Ignore |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          LAURUS_EOF => { // reduce
            let node = TokenConv::Ignore |> Node::TokenConv
            self.node_stack.push(node)
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
          LBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            46
          }
          Dot => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            47
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan6()
            49
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan21()
            50
          }
          CommentHead => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Ques => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Plus => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Star => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          EscNo => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Esc => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          LBrack => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Dot => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Or => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Percent => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          TokenName => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          SortName => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          LAURUS_EOF => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          _ => break
        }
    }
    42 => {
      self.enter_state(42)
      continue match lexeme.token {
          ColonColon => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan23()
            43
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::BuiltIn(x0) |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::BuiltIn(x0) |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::BuiltIn(x0) |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::BuiltIn(x0) |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::BuiltIn(x0) |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::BuiltIn(x0) |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::BuiltIn(x0) |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::BuiltIn(x0) |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::BuiltIn(x0) |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          Percent => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::BuiltIn(x0) |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          TokenName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::BuiltIn(x0) |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          SortName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::BuiltIn(x0) |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::BuiltIn(x0) |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          _ => break
        }
    }
    43 => {
      self.enter_state(43)
      continue match lexeme.token {
          MethodName => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            lexeme = self.lexer.scan6()
            44
          }
          _ => break
        }
    }
    44 => {
      self.enter_state(44)
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
            41
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
            41
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
            41
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
            41
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x2)
            // ignore Node [x1 : ColonColon]
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::Interpret(type_name=x0, parse_func_name=x2)
              |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x2)
            // ignore Node [x1 : ColonColon]
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::Interpret(type_name=x0, parse_func_name=x2)
              |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x2)
            // ignore Node [x1 : ColonColon]
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::Interpret(type_name=x0, parse_func_name=x2)
              |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x2)
            // ignore Node [x1 : ColonColon]
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::Interpret(type_name=x0, parse_func_name=x2)
              |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x2)
            // ignore Node [x1 : ColonColon]
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::Interpret(type_name=x0, parse_func_name=x2)
              |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          Percent => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x2)
            // ignore Node [x1 : ColonColon]
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::Interpret(type_name=x0, parse_func_name=x2)
              |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          TokenName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x2)
            // ignore Node [x1 : ColonColon]
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::Interpret(type_name=x0, parse_func_name=x2)
              |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          SortName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x2)
            // ignore Node [x1 : ColonColon]
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::Interpret(type_name=x0, parse_func_name=x2)
              |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::String(x2)
            // ignore Node [x1 : ColonColon]
            guard self.node_stack.unsafe_pop() is Node::String(x0)
            let node = TokenConv::Interpret(type_name=x0, parse_func_name=x2)
              |> Node::TokenConv
            self.node_stack.push(node)
            41
          }
          _ => break
        }
    }
    45 => {
      self.enter_state(45)
      continue match lexeme.token {
          Or => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            77
          }
          Star => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            79
          }
          Plus => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            80
          }
          Ques => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            81
          }
          LBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            46
          }
          Dot => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            47
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan6()
            49
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan21()
            50
          }
          LAURUS_EOF => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x3)
            guard self.node_stack.unsafe_pop() is Node::TokenConv(x2)
            guard self.node_stack.unsafe_pop() is Node::String(x1)
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::add_token(x0, x1, x2, x3) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          SortName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x3)
            guard self.node_stack.unsafe_pop() is Node::TokenConv(x2)
            guard self.node_stack.unsafe_pop() is Node::String(x1)
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::add_token(x0, x1, x2, x3) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          TokenName => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x3)
            guard self.node_stack.unsafe_pop() is Node::TokenConv(x2)
            guard self.node_stack.unsafe_pop() is Node::String(x1)
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::add_token(x0, x1, x2, x3) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          Percent => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x3)
            guard self.node_stack.unsafe_pop() is Node::TokenConv(x2)
            guard self.node_stack.unsafe_pop() is Node::String(x1)
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::add_token(x0, x1, x2, x3) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x3)
            guard self.node_stack.unsafe_pop() is Node::TokenConv(x2)
            guard self.node_stack.unsafe_pop() is Node::String(x1)
            guard self.node_stack.unsafe_pop() is Node::Laurus(x0)
            let node = Laurus::add_token(x0, x1, x2, x3) |> Node::Laurus
            self.node_stack.push(node)
            1
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = x0 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = x0 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = x0 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = x0 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = x0 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = x0 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = x0 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = x0 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          _ => break
        }
    }
    46 => {
      self.enter_state(46)
      continue match lexeme.token {
          Caret => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan25()
            56
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan24()
            59
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan21()
            60
          }
          _ => break
        }
    }
    47 => {
      self.enter_state(47)
      continue match lexeme.token {
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            // ignore Node [x0 : Dot]
            let node = RegExp::Any |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          _ => break
        }
    }
    48 => {
      self.enter_state(48)
      continue match lexeme.token {
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = RegExp::Single(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          _ => break
        }
    }
    49 => {
      self.enter_state(49)
      continue match lexeme.token {
          CommentHead => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
              _ => break
            }
          }
          _ => break
        }
    }
    50 => {
      self.enter_state(50)
      continue match lexeme.token {
          EscOrigin => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan6()
            51
          }
          EscSpace => { // shift
            let node = self.lexer.get(lexeme) |> Char::esc_space |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan6()
            52
          }
          EscU => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan26()
            53
          }
          _ => break
        }
    }
    51 => {
      self.enter_state(51)
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
              _ => break
            }
          }
          _ => break
        }
    }
    52 => {
      self.enter_state(52)
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
              _ => break
            }
          }
          _ => break
        }
    }
    53 => {
      self.enter_state(53)
      continue match lexeme.token {
          EscUnicode => { // shift
            let node = self.lexer.get(lexeme) |> Char::esc_unicode |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan6()
            54
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
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
              _ => break
            }
          }
          _ => break
        }
    }
    55 => {
      self.enter_state(55)
      continue match lexeme.token {
          RBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            76
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan24()
            59
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan21()
            60
          }
          _ => break
        }
    }
    56 => {
      self.enter_state(56)
      continue match lexeme.token {
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan24()
            59
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan21()
            60
          }
          _ => break
        }
    }
    57 => {
      self.enter_state(57)
      continue match lexeme.token {
          RBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Range(x0)
            let node = Array::singleton(x0) |> Node::Array_LB_Range_RB_
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 55
              56 => 73
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
              46 => 55
              56 => 73
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
              46 => 55
              56 => 73
              _ => break
            }
          }
          _ => break
        }
    }
    58 => {
      self.enter_state(58)
      continue match lexeme.token {
          Dash => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan25()
            65
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = Range::single(x0) |> Node::Range
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 57
              55 => 75
              56 => 57
              73 => 75
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
              46 => 57
              55 => 75
              56 => 57
              73 => 75
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
              46 => 57
              55 => 75
              56 => 57
              73 => 75
              _ => break
            }
          }
          _ => break
        }
    }
    59 => {
      self.enter_state(59)
      continue match lexeme.token {
          Dash => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
              _ => break
            }
          }
          _ => break
        }
    }
    60 => {
      self.enter_state(60)
      continue match lexeme.token {
          EscOrigin => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan24()
            61
          }
          EscSpace => { // shift
            let node = self.lexer.get(lexeme) |> Char::esc_space |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan24()
            62
          }
          EscU => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan26()
            63
          }
          _ => break
        }
    }
    61 => {
      self.enter_state(61)
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
              _ => break
            }
          }
          _ => break
        }
    }
    63 => {
      self.enter_state(63)
      continue match lexeme.token {
          EscUnicode => { // shift
            let node = self.lexer.get(lexeme) |> Char::esc_unicode |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan24()
            64
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
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
              _ => break
            }
          }
          _ => break
        }
    }
    65 => {
      self.enter_state(65)
      continue match lexeme.token {
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan27()
            67
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan21()
            68
          }
          _ => break
        }
    }
    66 => {
      self.enter_state(66)
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
              46 => 57
              55 => 75
              56 => 57
              73 => 75
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
              46 => 57
              55 => 75
              56 => 57
              73 => 75
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
              46 => 57
              55 => 75
              56 => 57
              73 => 75
              _ => break
            }
          }
          _ => break
        }
    }
    67 => {
      self.enter_state(67)
      continue match lexeme.token {
          RBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x0)
            let node = x0 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
              _ => break
            }
          }
          _ => break
        }
    }
    68 => {
      self.enter_state(68)
      continue match lexeme.token {
          EscOrigin => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan27()
            69
          }
          EscSpace => { // shift
            let node = self.lexer.get(lexeme) |> Char::esc_space |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan27()
            70
          }
          EscU => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan26()
            71
          }
          _ => break
        }
    }
    69 => {
      self.enter_state(69)
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x1)
            // ignore Node [x0 : Esc]
            let node = x1 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
              _ => break
            }
          }
          _ => break
        }
    }
    71 => {
      self.enter_state(71)
      continue match lexeme.token {
          EscUnicode => { // shift
            let node = self.lexer.get(lexeme) |> Char::esc_unicode |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan27()
            72
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
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::Char(x2)
            // ignore Node [x1 : EscU]
            // ignore Node [x0 : Esc]
            let node = x2 |> Node::Char
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
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
              41 => 48
              45 => 48
              46 => 58
              55 => 58
              56 => 58
              65 => 66
              73 => 58
              77 => 48
              78 => 48
              82 => 48
              83 => 48
              86 => 48
              _ => break
            }
          }
          _ => break
        }
    }
    73 => {
      self.enter_state(73)
      continue match lexeme.token {
          RBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            74
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan24()
            59
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan21()
            60
          }
          _ => break
        }
    }
    74 => {
      self.enter_state(74)
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
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
            guard self.node_stack.unsafe_pop() is Node::Range(x1)
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Range_RB_(x0)
            let node = Array::snoc(x0, x1) |> Node::Array_LB_Range_RB_
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              46 => 55
              56 => 73
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
              46 => 55
              56 => 73
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
              46 => 55
              56 => 73
              _ => break
            }
          }
          _ => break
        }
    }
    76 => {
      self.enter_state(76)
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          _ => break
        }
    }
    77 => {
      self.enter_state(77)
      continue match lexeme.token {
          LBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            46
          }
          Dot => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            47
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan6()
            49
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan21()
            50
          }
          LAURUS_EOF => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Ques => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Plus => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Star => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          EscNo => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Esc => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          LBrack => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Dot => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Or => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          SortName => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          TokenName => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Percent => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          CommentHead => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          _ => break
        }
    }
    78 => {
      self.enter_state(78)
      continue match lexeme.token {
          Or => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            77
          }
          Star => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            79
          }
          Plus => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            80
          }
          Ques => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            81
          }
          LBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            46
          }
          Dot => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            47
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan6()
            49
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan21()
            50
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Seq(x0, x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Seq(x0, x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Seq(x0, x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Seq(x0, x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x1)
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Seq(x0, x1) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
            // ignore Node [x1 : Star]
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = RegExp::Star(x0) |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          _ => break
        }
    }
    80 => {
      self.enter_state(80)
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          _ => break
        }
    }
    81 => {
      self.enter_state(81)
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          _ => break
        }
    }
    82 => {
      self.enter_state(82)
      continue match lexeme.token {
          Or => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            77
          }
          Star => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            79
          }
          Plus => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            80
          }
          Ques => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            81
          }
          LBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            46
          }
          Dot => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            47
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan6()
            49
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan21()
            50
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Ques => { // reduce
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Plus => { // reduce
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Star => { // reduce
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          EscNo => { // reduce
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Esc => { // reduce
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
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
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          _ => break
        }
    }
    83 => {
      self.enter_state(83)
      continue match lexeme.token {
          LBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            46
          }
          Dot => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            47
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan6()
            49
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan21()
            50
          }
          CommentHead => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Ques => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Plus => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Star => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          EscNo => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Esc => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          LBrack => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Dot => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Or => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Percent => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          TokenName => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          SortName => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          LAURUS_EOF => { // reduce
            let node = RegExp::Emp |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          _ => break
        }
    }
    84 => {
      self.enter_state(84)
      continue match lexeme.token {
          SortName => { // shift
            let node = self.lexer.get(lexeme) |> Node::String
            self.node_stack.push(node)
            lexeme = self.lexer.scan0()
            85
          }
          _ => break
        }
    }
    85 => {
      self.enter_state(85)
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
    86 => {
      self.enter_state(86)
      continue match lexeme.token {
          Or => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            77
          }
          Star => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            79
          }
          Plus => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            80
          }
          Ques => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            81
          }
          LBrack => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan22()
            46
          }
          Dot => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan6()
            47
          }
          EscNo => { // shift
            let node = self.lexer.get(lexeme) |> Char::get0 |> Node::Char
            self.node_stack.push(node)
            lexeme = self.lexer.scan6()
            49
          }
          Esc => { // shift
            // ignore the old lexeme
            lexeme = self.lexer.scan21()
            50
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
          Ques => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = x0 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Plus => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = x0 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Star => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = x0 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          EscNo => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = x0 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Esc => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = x0 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          LBrack => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = x0 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Dot => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = x0 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          Or => { // reduce
            self.state_stack.unsafe_pop() |> ignore
            guard self.node_stack.unsafe_pop() is Node::RegExp(x0)
            let node = x0 |> Node::RegExp
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              41 => 45
              45 => 78
              77 => 82
              78 => 78
              82 => 78
              83 => 86
              86 => 78
              _ => break
            }
          }
          _ => break
        }
    }
    87 => {
      self.enter_state(87)
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
