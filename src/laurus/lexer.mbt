///|
pub enum TOKEN {
  LAURUS_EOF
  LAURUS_SPACE
  Symbol
  TokenName
  SortName
  TypeName
  MethodName
  ConstructorName
  FieldName
  Space
  Start
  Shift
  Reduce
  Percent
  Eq
  Colon
  ColonColon
  Dot
  Star
  Plus
  Ques
  Dash
  Caret
  Or
  Tilde
  LParen
  RParen
  LBrack
  RBrack
  LBrace
  RBrace
  Esc
  EscU
  EscNo
  EscOrigin
  EscSpace
  EscUnicode
  CommentHead
  CommentBody
} derive(Show)

///|
pub struct Lexeme {
  mut token : TOKEN
  mut beg : Int
  mut end : Int
} derive(Show)

///|
fn Lexeme::new(beg? : Int = 0) -> Self {
  { token: LAURUS_EOF, beg, end: 0 }
}

///|
fn Lexeme::init(self : Self) -> Unit {
  self.token = LAURUS_EOF
  self.beg = 0
}

///|
struct Lexer {
  mut src : String
  mut cur : Int
  mut lexeme : Lexeme
} derive(Show)

///|
pub fn Lexer::new(src? : String = "") -> Self {
  { src, cur: 0, lexeme: Lexeme::new() }
}

///|
pub fn Lexer::init(self : Self, src : String, cur? : Int = 0) -> Unit {
  self.src = src
  self.cur = cur
  self.lexeme.init()
}

///|
pub fn Lexer::get(self : Self, lexeme : Lexeme) -> String {
  let beg = lexeme.beg
  let end = lexeme.end
  self.src.unsafe_substring(start=beg, end~)
}

///|
fn Lexer::next(self : Self) -> Int {
  if self.cur < self.src.length() {
    let c = self.src[self.cur]
    self.cur += 1
    c
  } else {
    -1
  }
}

///|
pub fn Lexer::skip_space(self : Self) -> Lexeme {
  loop 0 {
    0 => {
      self.lexeme.end = self.cur
      self.lexeme.token = LAURUS_SPACE
      continue match self.next() {
          '\t'..='\n' => 1
          ' ' => 1
          _ => break
        }
    }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = LAURUS_SPACE
      continue match self.next() {
          '\t'..='\n' => 1
          ' ' => 1
          _ => break
        }
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan0(self : Self) -> Lexeme {
  // [LAURUS_EOF, TokenName, SortName, Percent, CommentHead]
  self.skip_space() |> ignore
  loop 0 {
    0 => {
      self.lexeme.end = self.cur
      self.lexeme.token = LAURUS_EOF
      continue match self.next() {
          '%' => 1
          '/' => 2
          'A'..='Z' => 3
          'a'..='z' => 4
          _ => break
        }
    }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Percent
      break
    }
    2 =>
      continue match self.next() {
          '/' => 5
          _ => break
        }
    3 => {
      self.lexeme.end = self.cur
      self.lexeme.token = TokenName
      continue match self.next() {
          '0'..='9' => 3
          'A'..='Z' => 3
          '_' => 3
          'a'..='z' => 3
          _ => break
        }
    }
    4 => {
      self.lexeme.end = self.cur
      self.lexeme.token = SortName
      continue match self.next() {
          '0'..='9' => 4
          'A'..='Z' => 4
          '_' => 4
          'a'..='z' => 4
          _ => break
        }
    }
    5 => {
      self.lexeme.end = self.cur
      self.lexeme.token = CommentHead
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan1(self : Self) -> Lexeme {
  // [Colon, LBrace]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          ':' => 1
          '{' => 2
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Colon
      break
    }
    2 => {
      self.lexeme.end = self.cur
      self.lexeme.token = LBrace
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan2(self : Self) -> Lexeme {
  // [LAURUS_EOF, TokenName, SortName, TypeName, Percent, Dot, Star, Plus, Ques, Or, LBrack, Esc, EscNo, CommentHead]
  self.skip_space() |> ignore
  loop 0 {
    0 => {
      self.lexeme.end = self.cur
      self.lexeme.token = LAURUS_EOF
      continue match self.next() {
          '\u{0}'..='$' => 1
          '%' => 2
          '&'..='\'' => 1
          '*' => 3
          '+' => 4
          '.' => 5
          '/' => 6
          '0'..='>' => 1
          '?' => 7
          '@' => 1
          'A'..='Z' => 8
          '[' => 9
          '\\' => 10
          '_'..='`' => 1
          'a'..='z' => 11
          '{' => 1
          '|' => 12
          '}'..='\u{10FFFF}' => 1
          _ => break
        }
    }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = EscNo
      break
    }
    2 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Percent
      break
    }
    3 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Star
      break
    }
    4 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Plus
      break
    }
    5 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Dot
      break
    }
    6 =>
      continue match self.next() {
          '/' => 15
          _ => break
        }
    7 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Ques
      break
    }
    8 => {
      self.lexeme.end = self.cur
      self.lexeme.token = TokenName
      continue match self.next() {
          '0'..='9' => 14
          'A'..='Z' => 14
          '_' => 14
          'a'..='z' => 14
          _ => break
        }
    }
    9 => {
      self.lexeme.end = self.cur
      self.lexeme.token = LBrack
      break
    }
    10 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Esc
      break
    }
    11 => {
      self.lexeme.end = self.cur
      self.lexeme.token = SortName
      continue match self.next() {
          '0'..='9' => 13
          'A'..='Z' => 13
          '_' => 13
          'a'..='z' => 13
          _ => break
        }
    }
    12 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Or
      break
    }
    13 => {
      self.lexeme.end = self.cur
      self.lexeme.token = SortName
      continue match self.next() {
          '0'..='9' => 13
          'A'..='Z' => 13
          '_' => 13
          'a'..='z' => 13
          _ => break
        }
    }
    14 => {
      self.lexeme.end = self.cur
      self.lexeme.token = TokenName
      continue match self.next() {
          '0'..='9' => 14
          'A'..='Z' => 14
          '_' => 14
          'a'..='z' => 14
          _ => break
        }
    }
    15 => {
      self.lexeme.end = self.cur
      self.lexeme.token = CommentHead
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan3(self : Self) -> Lexeme {
  // [Space, Start]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          's' => 1
          _ => break
        }
    1 =>
      continue match self.next() {
          'p' => 2
          't' => 3
          _ => break
        }
    2 =>
      continue match self.next() {
          'a' => 7
          _ => break
        }
    3 =>
      continue match self.next() {
          'a' => 4
          _ => break
        }
    4 =>
      continue match self.next() {
          'r' => 5
          _ => break
        }
    5 =>
      continue match self.next() {
          't' => 6
          _ => break
        }
    6 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Start
      break
    }
    7 =>
      continue match self.next() {
          'c' => 8
          _ => break
        }
    8 =>
      continue match self.next() {
          'e' => 9
          _ => break
        }
    9 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Space
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan4(self : Self) -> Lexeme {
  // [CommentBody]
  self.skip_space() |> ignore
  loop 0 {
    0 => {
      self.lexeme.end = self.cur
      self.lexeme.token = CommentBody
      continue match self.next() {
          '\u{0}'..='\t' => 1
          ''..='\u{10FFFF}' => 1
          _ => break
        }
    }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = CommentBody
      continue match self.next() {
          '\u{0}'..='\t' => 1
          ''..='\u{10FFFF}' => 1
          _ => break
        }
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan5(self : Self) -> Lexeme {
  // [SortName]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          'a'..='z' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = SortName
      continue match self.next() {
          '0'..='9' => 1
          'A'..='Z' => 1
          '_' => 1
          'a'..='z' => 1
          _ => break
        }
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan6(self : Self) -> Lexeme {
  // [LAURUS_EOF, TokenName, SortName, Percent, Dot, Star, Plus, Ques, Or, LBrack, Esc, EscNo, CommentHead]
  self.skip_space() |> ignore
  loop 0 {
    0 => {
      self.lexeme.end = self.cur
      self.lexeme.token = LAURUS_EOF
      continue match self.next() {
          '\u{0}'..='$' => 1
          '%' => 2
          '&'..='\'' => 1
          '*' => 3
          '+' => 4
          '.' => 5
          '/' => 6
          '0'..='>' => 1
          '?' => 7
          '@' => 1
          'A'..='Z' => 8
          '[' => 9
          '\\' => 10
          '_'..='`' => 1
          'a'..='z' => 11
          '{' => 1
          '|' => 12
          '}'..='\u{10FFFF}' => 1
          _ => break
        }
    }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = EscNo
      break
    }
    2 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Percent
      break
    }
    3 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Star
      break
    }
    4 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Plus
      break
    }
    5 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Dot
      break
    }
    6 =>
      continue match self.next() {
          '/' => 15
          _ => break
        }
    7 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Ques
      break
    }
    8 => {
      self.lexeme.end = self.cur
      self.lexeme.token = TokenName
      continue match self.next() {
          '0'..='9' => 14
          'A'..='Z' => 14
          '_' => 14
          'a'..='z' => 14
          _ => break
        }
    }
    9 => {
      self.lexeme.end = self.cur
      self.lexeme.token = LBrack
      break
    }
    10 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Esc
      break
    }
    11 => {
      self.lexeme.end = self.cur
      self.lexeme.token = SortName
      continue match self.next() {
          '0'..='9' => 13
          'A'..='Z' => 13
          '_' => 13
          'a'..='z' => 13
          _ => break
        }
    }
    12 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Or
      break
    }
    13 => {
      self.lexeme.end = self.cur
      self.lexeme.token = SortName
      continue match self.next() {
          '0'..='9' => 13
          'A'..='Z' => 13
          '_' => 13
          'a'..='z' => 13
          _ => break
        }
    }
    14 => {
      self.lexeme.end = self.cur
      self.lexeme.token = TokenName
      continue match self.next() {
          '0'..='9' => 14
          'A'..='Z' => 14
          '_' => 14
          'a'..='z' => 14
          _ => break
        }
    }
    15 => {
      self.lexeme.end = self.cur
      self.lexeme.token = CommentHead
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan7(self : Self) -> Lexeme {
  // [LAURUS_EOF, TokenName, SortName, Percent, ColonColon, Dot, Star, Plus, Ques, Or, LBrack, Esc, EscNo, CommentHead]
  self.skip_space() |> ignore
  loop 0 {
    0 => {
      self.lexeme.end = self.cur
      self.lexeme.token = LAURUS_EOF
      continue match self.next() {
          '\u{0}'..='$' => 1
          '%' => 2
          '&'..='\'' => 1
          '*' => 3
          '+' => 4
          '.' => 5
          '/' => 6
          '0'..='>' => 1
          '?' => 7
          '@' => 1
          'A'..='Z' => 8
          '[' => 9
          '\\' => 10
          '_'..='`' => 1
          'a'..='z' => 11
          '{' => 1
          '|' => 12
          '}'..='\u{10FFFF}' => 1
          _ => break
        }
    }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = EscNo
      break
    }
    2 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Percent
      continue match self.next() {
          '%' => 16
          _ => break
        }
    }
    3 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Star
      break
    }
    4 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Plus
      break
    }
    5 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Dot
      break
    }
    6 =>
      continue match self.next() {
          '/' => 15
          _ => break
        }
    7 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Ques
      break
    }
    8 => {
      self.lexeme.end = self.cur
      self.lexeme.token = TokenName
      continue match self.next() {
          '0'..='9' => 14
          'A'..='Z' => 14
          '_' => 14
          'a'..='z' => 14
          _ => break
        }
    }
    9 => {
      self.lexeme.end = self.cur
      self.lexeme.token = LBrack
      break
    }
    10 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Esc
      break
    }
    11 => {
      self.lexeme.end = self.cur
      self.lexeme.token = SortName
      continue match self.next() {
          '0'..='9' => 13
          'A'..='Z' => 13
          '_' => 13
          'a'..='z' => 13
          _ => break
        }
    }
    12 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Or
      break
    }
    13 => {
      self.lexeme.end = self.cur
      self.lexeme.token = SortName
      continue match self.next() {
          '0'..='9' => 13
          'A'..='Z' => 13
          '_' => 13
          'a'..='z' => 13
          _ => break
        }
    }
    14 => {
      self.lexeme.end = self.cur
      self.lexeme.token = TokenName
      continue match self.next() {
          '0'..='9' => 14
          'A'..='Z' => 14
          '_' => 14
          'a'..='z' => 14
          _ => break
        }
    }
    15 => {
      self.lexeme.end = self.cur
      self.lexeme.token = CommentHead
      break
    }
    16 => {
      self.lexeme.end = self.cur
      self.lexeme.token = ColonColon
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan8(self : Self) -> Lexeme {
  // [TypeName]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          'A'..='Z' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = TypeName
      continue match self.next() {
          '0'..='9' => 1
          'A'..='Z' => 1
          '_' => 1
          'a'..='z' => 1
          _ => break
        }
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan9(self : Self) -> Lexeme {
  // [Eq, Or, RBrace]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '=' => 1
          '|' => 2
          '}' => 3
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Eq
      break
    }
    2 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Or
      break
    }
    3 => {
      self.lexeme.end = self.cur
      self.lexeme.token = RBrace
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan10(self : Self) -> Lexeme {
  // [LBrack, LBrace]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '[' => 1
          '{' => 2
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = LBrack
      break
    }
    2 => {
      self.lexeme.end = self.cur
      self.lexeme.token = LBrace
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan11(self : Self) -> Lexeme {
  // [LBrack, RBrack]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '[' => 1
          ']' => 2
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = LBrack
      break
    }
    2 => {
      self.lexeme.end = self.cur
      self.lexeme.token = RBrack
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan12(self : Self) -> Lexeme {
  // [LBrace]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '{' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = LBrace
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan13(self : Self) -> Lexeme {
  // [RBrack]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          ']' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = RBrack
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan14(self : Self) -> Lexeme {
  // [MethodName, ConstructorName, Shift, Reduce, LParen]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '(' => 1
          '@' => 2
          'A'..='Z' => 3
          'a'..='z' => 4
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = LParen
      break
    }
    2 =>
      continue match self.next() {
          'l' => 5
          'r' => 6
          's' => 7
          _ => break
        }
    3 => {
      self.lexeme.end = self.cur
      self.lexeme.token = ConstructorName
      continue match self.next() {
          '0'..='9' => 3
          'A'..='Z' => 3
          '_' => 3
          'a'..='z' => 3
          _ => break
        }
    }
    4 => {
      self.lexeme.end = self.cur
      self.lexeme.token = MethodName
      continue match self.next() {
          '0'..='9' => 4
          'A'..='Z' => 4
          '_' => 4
          'a'..='z' => 4
          _ => break
        }
    }
    5 =>
      continue match self.next() {
          'e' => 19
          _ => break
        }
    6 =>
      continue match self.next() {
          'e' => 12
          'i' => 13
          _ => break
        }
    7 =>
      continue match self.next() {
          'h' => 8
          _ => break
        }
    8 =>
      continue match self.next() {
          'i' => 9
          _ => break
        }
    9 =>
      continue match self.next() {
          'f' => 10
          _ => break
        }
    10 =>
      continue match self.next() {
          't' => 11
          _ => break
        }
    11 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Shift
      break
    }
    12 =>
      continue match self.next() {
          'd' => 15
          _ => break
        }
    13 =>
      continue match self.next() {
          'g' => 14
          _ => break
        }
    14 =>
      continue match self.next() {
          'h' => 10
          _ => break
        }
    15 =>
      continue match self.next() {
          'u' => 16
          _ => break
        }
    16 =>
      continue match self.next() {
          'c' => 17
          _ => break
        }
    17 =>
      continue match self.next() {
          'e' => 18
          _ => break
        }
    18 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Reduce
      break
    }
    19 =>
      continue match self.next() {
          'f' => 20
          _ => break
        }
    20 =>
      continue match self.next() {
          't' => 18
          _ => break
        }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan15(self : Self) -> Lexeme {
  // [MethodName, ConstructorName, LParen]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '(' => 1
          'A'..='Z' => 2
          'a'..='z' => 3
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = LParen
      break
    }
    2 => {
      self.lexeme.end = self.cur
      self.lexeme.token = ConstructorName
      continue match self.next() {
          '0'..='9' => 2
          'A'..='Z' => 2
          '_' => 2
          'a'..='z' => 2
          _ => break
        }
    }
    3 => {
      self.lexeme.end = self.cur
      self.lexeme.token = MethodName
      continue match self.next() {
          '0'..='9' => 3
          'A'..='Z' => 3
          '_' => 3
          'a'..='z' => 3
          _ => break
        }
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan16(self : Self) -> Lexeme {
  // [LParen]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '(' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = LParen
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan17(self : Self) -> Lexeme {
  // [Symbol, RParen, LBrack]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          ')' => 1
          'A'..='Z' => 2
          '[' => 3
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = RParen
      break
    }
    2 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Symbol
      continue match self.next() {
          '0'..='9' => 2
          'A'..='Z' => 2
          '_' => 2
          'a'..='z' => 2
          _ => break
        }
    }
    3 => {
      self.lexeme.end = self.cur
      self.lexeme.token = LBrack
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan18(self : Self) -> Lexeme {
  // [FieldName]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          'a'..='z' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = FieldName
      continue match self.next() {
          '0'..='9' => 1
          'A'..='Z' => 1
          '_' => 1
          'a'..='z' => 1
          _ => break
        }
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan19(self : Self) -> Lexeme {
  // [Colon, Tilde]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          ':' => 1
          '~' => 2
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Colon
      break
    }
    2 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Tilde
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan20(self : Self) -> Lexeme {
  // [Symbol]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          'A'..='Z' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Symbol
      continue match self.next() {
          '0'..='9' => 1
          'A'..='Z' => 1
          '_' => 1
          'a'..='z' => 1
          _ => break
        }
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan21(self : Self) -> Lexeme {
  // [EscU, EscOrigin, EscSpace]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '('..='+' => 1
          '-'..='/' => 1
          '?' => 1
          '['..='^' => 1
          'n' => 2
          's'..='t' => 2
          'u' => 3
          '|' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = EscOrigin
      break
    }
    2 => {
      self.lexeme.end = self.cur
      self.lexeme.token = EscSpace
      break
    }
    3 => {
      self.lexeme.end = self.cur
      self.lexeme.token = EscU
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan22(self : Self) -> Lexeme {
  // [Caret, Esc, EscNo]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '\u{0}'..='\'' => 1
          '0'..='>' => 1
          '@'..='Z' => 1
          '\\' => 2
          '^' => 3
          '_'..='{' => 1
          '}'..='\u{10FFFF}' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = EscNo
      break
    }
    2 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Esc
      break
    }
    3 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Caret
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan23(self : Self) -> Lexeme {
  // [MethodName]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          'a'..='z' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = MethodName
      continue match self.next() {
          '0'..='9' => 1
          'A'..='Z' => 1
          '_' => 1
          'a'..='z' => 1
          _ => break
        }
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan24(self : Self) -> Lexeme {
  // [Dash, RBrack, Esc, EscNo]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '\u{0}'..='\'' => 1
          '-' => 2
          '0'..='>' => 1
          '@'..='Z' => 1
          '\\' => 3
          ']' => 4
          '_'..='{' => 1
          '}'..='\u{10FFFF}' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = EscNo
      break
    }
    2 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Dash
      break
    }
    3 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Esc
      break
    }
    4 => {
      self.lexeme.end = self.cur
      self.lexeme.token = RBrack
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan25(self : Self) -> Lexeme {
  // [Esc, EscNo]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '\u{0}'..='\'' => 1
          '0'..='>' => 1
          '@'..='Z' => 1
          '\\' => 2
          '_'..='{' => 1
          '}'..='\u{10FFFF}' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = EscNo
      break
    }
    2 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Esc
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan26(self : Self) -> Lexeme {
  // [EscUnicode]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '0' => 1
          '1' => 2
          '2'..='9' => 1
          'A'..='F' => 1
          'a'..='f' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = EscUnicode
      continue match self.next() {
          '0'..='9' => 4
          'A'..='F' => 4
          'a'..='f' => 4
          _ => break
        }
    }
    2 => {
      self.lexeme.end = self.cur
      self.lexeme.token = EscUnicode
      continue match self.next() {
          '0' => 3
          '1'..='9' => 4
          'A'..='F' => 4
          'a'..='f' => 4
          _ => break
        }
    }
    3 => {
      self.lexeme.end = self.cur
      self.lexeme.token = EscUnicode
      continue match self.next() {
          '0'..='9' => 8
          'A'..='F' => 8
          'a'..='f' => 8
          _ => break
        }
    }
    4 => {
      self.lexeme.end = self.cur
      self.lexeme.token = EscUnicode
      continue match self.next() {
          '0'..='9' => 5
          'A'..='F' => 5
          'a'..='f' => 5
          _ => break
        }
    }
    5 => {
      self.lexeme.end = self.cur
      self.lexeme.token = EscUnicode
      continue match self.next() {
          '0'..='9' => 6
          'A'..='F' => 6
          'a'..='f' => 6
          _ => break
        }
    }
    6 => {
      self.lexeme.end = self.cur
      self.lexeme.token = EscUnicode
      continue match self.next() {
          '0'..='9' => 7
          'A'..='F' => 7
          'a'..='f' => 7
          _ => break
        }
    }
    7 => {
      self.lexeme.end = self.cur
      self.lexeme.token = EscUnicode
      break
    }
    8 => {
      self.lexeme.end = self.cur
      self.lexeme.token = EscUnicode
      continue match self.next() {
          '0'..='9' => 9
          'A'..='F' => 9
          'a'..='f' => 9
          _ => break
        }
    }
    9 => {
      self.lexeme.end = self.cur
      self.lexeme.token = EscUnicode
      continue match self.next() {
          '0'..='9' => 10
          'A'..='F' => 10
          'a'..='f' => 10
          _ => break
        }
    }
    10 => {
      self.lexeme.end = self.cur
      self.lexeme.token = EscUnicode
      continue match self.next() {
          '0'..='9' => 11
          'A'..='F' => 11
          'a'..='f' => 11
          _ => break
        }
    }
    11 =>
      continue match self.next() {
          '0'..='9' => 7
          'A'..='F' => 7
          'a'..='f' => 7
          _ => break
        }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan27(self : Self) -> Lexeme {
  // [RBrack, Esc, EscNo]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '\u{0}'..='\'' => 1
          '0'..='>' => 1
          '@'..='Z' => 1
          '\\' => 2
          ']' => 3
          '_'..='{' => 1
          '}'..='\u{10FFFF}' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = EscNo
      break
    }
    2 => {
      self.lexeme.end = self.cur
      self.lexeme.token = Esc
      break
    }
    3 => {
      self.lexeme.end = self.cur
      self.lexeme.token = RBrack
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
}
