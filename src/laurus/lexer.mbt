///|
pub enum TOKEN {
  LAURUS_ERROR
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
  Lt
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
suberror LexerError {
  ExpectTokens(Location, Location, Array[TOKEN])
}

///|
pub struct Location {
  mut row : Int
  mut col : Int
  mut off : Int
} derive(Show)

///|
impl Default for Location with default() {
  Location::{ row: 1, col: 0, off: 0 }
}

///|
fn Location::clone(self : Self) -> Self {
  let { row, col, off } = self
  { row, col, off }
}

///|
pub struct Lexeme {
  mut token : TOKEN
  mut beg : Location
  mut end : Location
} derive(Show)

///|
fn Lexeme::new(beg? : Location = Location::default()) -> Self {
  { token: LAURUS_ERROR, beg, end: Location::default() }
}

///|
fn Lexeme::init(self : Self) -> Unit {
  self.token = LAURUS_ERROR
  self.beg = Location::default()
}

///|
struct Lexer {
  mut src : String
  mut cur : Location
  mut lexeme : Lexeme
} derive(Show)

///|
pub fn Lexer::new(src? : String = "") -> Self {
  { src, cur: Location::default(), lexeme: Lexeme::new() }
}

///|
pub fn Lexer::init(
  self : Self,
  src : String,
  cur? : Location = Location::default(),
) -> Unit {
  self.src = src
  self.cur = cur
  self.lexeme.init()
}

///|
#inline
pub fn Lexer::cur_loc(self : Self) -> Location {
  self.cur.clone()
}

///|
pub fn Lexer::get(self : Self, lexeme : Lexeme) -> String {
  let beg = lexeme.beg
  let end = lexeme.end
  self.src.unsafe_substring(start=beg.off, end=end.off)
}

///|
fn Lexer::next(self : Self) -> Int {
  let cur_off = self.cur.off
  guard cur_off < self.src.length() else { -1 }
  match self.src[cur_off] {
    0xD800..=0xDBFF as lead => {
      let tail = self.src[cur_off + 1]
      self.cur.off += 2
      self.cur.col += 1
      (((lead & 0x3FF) << 10) | (tail & 0x3FF)) + 0x10000
    }
    0xA as c => {
      self.cur.off += 1
      self.cur.row += 1
      self.cur.col = 0
      c
    }
    _ as c => {
      self.cur.off += 1
      self.cur.col += 1
      c
    }
  }
}

///|
pub fn Lexer::skip_space(self : Self) -> Lexeme raise LexerError {
  loop 0 {
    0 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LAURUS_SPACE
      continue match self.next() {
          '\t'..='\n' => 0
          ' ' => 0
          _ => break
        }
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [LAURUS_SPACE])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan0(self : Self) -> Lexeme raise LexerError {
  // [LAURUS_EOF, TokenName, SortName, Percent, CommentHead]
  self.skip_space() |> ignore
  loop 0 {
    0 => {
      self.lexeme.end = self.cur.clone()
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
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Percent
      break
    }
    2 =>
      continue match self.next() {
          '/' => 5
          _ => break
        }
    3 => {
      self.lexeme.end = self.cur.clone()
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
      self.lexeme.end = self.cur.clone()
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
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = CommentHead
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [
      LAURUS_EOF,
      TokenName,
      SortName,
      Percent,
      CommentHead,
    ])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan1(self : Self) -> Lexeme raise LexerError {
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
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Colon
      break
    }
    2 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LBrace
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [
      Colon,
      LBrace,
    ])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan2(self : Self) -> Lexeme raise LexerError {
  // [Eq]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '=' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Eq
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [Eq])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan3(self : Self) -> Lexeme raise LexerError {
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
      self.lexeme.end = self.cur.clone()
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
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Space
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [Space, Start])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan4(self : Self) -> Lexeme raise LexerError {
  // [CommentBody]
  self.skip_space() |> ignore
  loop 0 {
    0 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = CommentBody
      continue match self.next() {
          '\u{0}'..='\t' => 1
          ''..='\u{10FFFF}' => 1
          _ => break
        }
    }
    1 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = CommentBody
      continue match self.next() {
          '\u{0}'..='\t' => 1
          ''..='\u{10FFFF}' => 1
          _ => break
        }
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [CommentBody])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan5(self : Self) -> Lexeme raise LexerError {
  // [SortName]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          'a'..='z' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur.clone()
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
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [SortName])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan6(self : Self) -> Lexeme raise LexerError {
  // [Dot, LParen, LBrack, Esc, EscNo]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '\u{0}'..='\'' => 1
          '(' => 2
          '.' => 3
          '0'..='>' => 1
          '@'..='Z' => 1
          '[' => 4
          '\\' => 5
          '_'..='{' => 1
          '}'..='\u{10FFFF}' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = EscNo
      break
    }
    2 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LParen
      break
    }
    3 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Dot
      break
    }
    4 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LBrack
      break
    }
    5 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Esc
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [
      Dot,
      LParen,
      LBrack,
      Esc,
      EscNo,
    ])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan7(self : Self) -> Lexeme raise LexerError {
  // [TypeName, LParen]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '(' => 1
          'A'..='Z' => 2
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LParen
      break
    }
    2 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = TypeName
      continue match self.next() {
          '0'..='9' => 2
          'A'..='Z' => 2
          '_' => 2
          'a'..='z' => 2
          _ => break
        }
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [
      TypeName,
      LParen,
    ])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan8(self : Self) -> Lexeme raise LexerError {
  // [TypeName]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          'A'..='Z' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur.clone()
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
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [TypeName])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan9(self : Self) -> Lexeme raise LexerError {
  // [Or, Lt, RBrace]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '<' => 1
          '|' => 2
          '}' => 3
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Lt
      break
    }
    2 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Or
      break
    }
    3 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = RBrace
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [
      Or,
      Lt,
      RBrace,
    ])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan10(self : Self) -> Lexeme raise LexerError {
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
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LBrack
      break
    }
    2 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LBrace
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [
      LBrack,
      LBrace,
    ])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan11(self : Self) -> Lexeme raise LexerError {
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
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LBrack
      break
    }
    2 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = RBrack
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [
      LBrack,
      RBrack,
    ])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan12(self : Self) -> Lexeme raise LexerError {
  // [LBrace]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '{' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LBrace
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [LBrace])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan13(self : Self) -> Lexeme raise LexerError {
  // [RBrack]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          ']' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = RBrack
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [RBrack])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan14(self : Self) -> Lexeme raise LexerError {
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
      self.lexeme.end = self.cur.clone()
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
      self.lexeme.end = self.cur.clone()
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
      self.lexeme.end = self.cur.clone()
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
      self.lexeme.end = self.cur.clone()
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
      self.lexeme.end = self.cur.clone()
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
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [
      MethodName,
      ConstructorName,
      Shift,
      Reduce,
      LParen,
    ])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan15(self : Self) -> Lexeme raise LexerError {
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
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LParen
      break
    }
    2 => {
      self.lexeme.end = self.cur.clone()
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
      self.lexeme.end = self.cur.clone()
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
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [
      MethodName,
      ConstructorName,
      LParen,
    ])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan16(self : Self) -> Lexeme raise LexerError {
  // [LParen]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '(' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LParen
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [LParen])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan17(self : Self) -> Lexeme raise LexerError {
  // [Symbol, RParen, LBrack]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          ')' => 1
          'A'..='Z' => 2
          '[' => 3
          'a'..='z' => 2
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = RParen
      break
    }
    2 => {
      self.lexeme.end = self.cur.clone()
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
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LBrack
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [
      Symbol,
      RParen,
      LBrack,
    ])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan18(self : Self) -> Lexeme raise LexerError {
  // [FieldName]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          'a'..='z' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur.clone()
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
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [FieldName])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan19(self : Self) -> Lexeme raise LexerError {
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
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Colon
      break
    }
    2 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Tilde
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [Colon, Tilde])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan20(self : Self) -> Lexeme raise LexerError {
  // [Symbol]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          'A'..='Z' => 1
          'a'..='z' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur.clone()
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
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [Symbol])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan21(self : Self) -> Lexeme raise LexerError {
  // [ColonColon, LParen]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '(' => 1
          ':' => 2
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LParen
      break
    }
    2 =>
      continue match self.next() {
          ':' => 3
          _ => break
        }
    3 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = ColonColon
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [
      ColonColon,
      LParen,
    ])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan22(self : Self) -> Lexeme raise LexerError {
  // [MethodName]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          'a'..='z' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur.clone()
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
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [MethodName])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan23(self : Self) -> Lexeme raise LexerError {
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
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = EscOrigin
      break
    }
    2 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = EscSpace
      break
    }
    3 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = EscU
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [
      EscU,
      EscOrigin,
      EscSpace,
    ])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan24(self : Self) -> Lexeme raise LexerError {
  // [Dot, Star, Plus, Ques, Or, LParen, RParen, LBrack, Esc, EscNo]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '\u{0}'..='\'' => 1
          '(' => 2
          ')' => 3
          '*' => 4
          '+' => 5
          '.' => 6
          '0'..='>' => 1
          '?' => 7
          '@'..='Z' => 1
          '[' => 8
          '\\' => 9
          '_'..='{' => 1
          '|' => 10
          '}'..='\u{10FFFF}' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = EscNo
      break
    }
    2 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LParen
      break
    }
    3 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = RParen
      break
    }
    4 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Star
      break
    }
    5 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Plus
      break
    }
    6 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Dot
      break
    }
    7 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Ques
      break
    }
    8 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LBrack
      break
    }
    9 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Esc
      break
    }
    10 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Or
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [
      Dot,
      Star,
      Plus,
      Ques,
      Or,
      LParen,
      RParen,
      LBrack,
      Esc,
      EscNo,
    ])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan25(self : Self) -> Lexeme raise LexerError {
  // [Caret, RBrack, Esc, EscNo]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '\u{0}'..='\'' => 1
          '0'..='>' => 1
          '@'..='Z' => 1
          '\\' => 2
          ']' => 3
          '^' => 4
          '_'..='{' => 1
          '}'..='\u{10FFFF}' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = EscNo
      break
    }
    2 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Esc
      break
    }
    3 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = RBrack
      break
    }
    4 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Caret
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [
      Caret,
      RBrack,
      Esc,
      EscNo,
    ])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan26(self : Self) -> Lexeme raise LexerError {
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
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = EscNo
      break
    }
    2 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Dash
      break
    }
    3 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Esc
      break
    }
    4 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = RBrack
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [
      Dash,
      RBrack,
      Esc,
      EscNo,
    ])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan27(self : Self) -> Lexeme raise LexerError {
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
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = EscNo
      break
    }
    2 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Esc
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [Esc, EscNo])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan28(self : Self) -> Lexeme raise LexerError {
  // [EscUnicode]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '0' => 1
          '1' => 1
          '2'..='9' => 1
          'A'..='F' => 1
          'a'..='f' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = EscUnicode
      continue match self.next() {
          '0' => 1
          '1' => 1
          '2'..='9' => 1
          'A'..='F' => 1
          'a'..='f' => 1
          _ => break
        }
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [EscUnicode])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan29(self : Self) -> Lexeme raise LexerError {
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
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = EscNo
      break
    }
    2 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Esc
      break
    }
    3 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = RBrack
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [
      RBrack,
      Esc,
      EscNo,
    ])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan30(self : Self) -> Lexeme raise LexerError {
  // [LAURUS_EOF, TokenName, SortName, Percent, Dot, Star, Plus, Ques, Or, LParen, LBrack, Esc, EscNo, CommentHead]
  self.skip_space() |> ignore
  loop 0 {
    0 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LAURUS_EOF
      continue match self.next() {
          '\u{0}'..='$' => 1
          '%' => 2
          '&'..='\'' => 1
          '(' => 3
          '*' => 4
          '+' => 5
          '.' => 6
          '/' => 7
          '0'..='>' => 1
          '?' => 8
          '@' => 1
          'A'..='Z' => 9
          '[' => 10
          '\\' => 11
          '_'..='`' => 1
          'a'..='z' => 12
          '{' => 1
          '|' => 13
          '}'..='\u{10FFFF}' => 1
          _ => break
        }
    }
    1 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = EscNo
      break
    }
    2 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Percent
      break
    }
    3 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LParen
      break
    }
    4 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Star
      break
    }
    5 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Plus
      break
    }
    6 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Dot
      break
    }
    7 =>
      continue match self.next() {
          '/' => 16
          _ => break
        }
    8 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Ques
      break
    }
    9 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = TokenName
      continue match self.next() {
          '0'..='9' => 15
          'A'..='Z' => 15
          '_' => 15
          'a'..='z' => 15
          _ => break
        }
    }
    10 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LBrack
      break
    }
    11 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Esc
      break
    }
    12 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = SortName
      continue match self.next() {
          '0'..='9' => 14
          'A'..='Z' => 14
          '_' => 14
          'a'..='z' => 14
          _ => break
        }
    }
    13 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Or
      break
    }
    14 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = SortName
      continue match self.next() {
          '0'..='9' => 14
          'A'..='Z' => 14
          '_' => 14
          'a'..='z' => 14
          _ => break
        }
    }
    15 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = TokenName
      continue match self.next() {
          '0'..='9' => 15
          'A'..='Z' => 15
          '_' => 15
          'a'..='z' => 15
          _ => break
        }
    }
    16 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = CommentHead
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [
      LAURUS_EOF,
      TokenName,
      SortName,
      Percent,
      Dot,
      Star,
      Plus,
      Ques,
      Or,
      LParen,
      LBrack,
      Esc,
      EscNo,
      CommentHead,
    ])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}
