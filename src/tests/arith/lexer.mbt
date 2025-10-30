///|
pub enum TOKEN {
  LAURUS_ERROR
  LAURUS_EOF
  LAURUS_SPACE
  Lit
  Add
  Sub
  Mul
  Div
  Pow
  LParen
  RParen
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
  // [Lit, LParen]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '(' => 1
          '0' => 2
          '1'..='9' => 3
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LParen
      break
    }
    2 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Lit
      break
    }
    3 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Lit
      continue match self.next() {
          '0'..='9' => 3
          _ => break
        }
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [Lit, LParen])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan1(self : Self) -> Lexeme raise LexerError {
  // [LAURUS_EOF, Add, Sub, Mul, Div, Pow]
  self.skip_space() |> ignore
  loop 0 {
    0 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LAURUS_EOF
      continue match self.next() {
          '*' => 1
          '+' => 2
          '-' => 3
          '/' => 4
          '^' => 5
          _ => break
        }
    }
    1 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Mul
      break
    }
    2 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Add
      break
    }
    3 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Sub
      break
    }
    4 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Div
      break
    }
    5 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Pow
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [
      LAURUS_EOF,
      Add,
      Sub,
      Mul,
      Div,
      Pow,
    ])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan2(self : Self) -> Lexeme raise LexerError {
  // [Add, Sub, Mul, Div, Pow, RParen]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          ')' => 1
          '*' => 2
          '+' => 3
          '-' => 4
          '/' => 5
          '^' => 6
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = RParen
      break
    }
    2 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Mul
      break
    }
    3 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Add
      break
    }
    4 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Sub
      break
    }
    5 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Div
      break
    }
    6 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Pow
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [
      Add,
      Sub,
      Mul,
      Div,
      Pow,
      RParen,
    ])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}
