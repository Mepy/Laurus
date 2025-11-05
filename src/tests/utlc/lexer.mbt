///|
pub enum TOKEN {
  LAURUS_ERROR
  LAURUS_EOF
  LAURUS_SPACE
  Var
  Lam
  Arr
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
  // [Var, Lam, LParen]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '(' => 1
          'A'..='Z' => 2
          '\\' => 3
          '_' => 2
          'a'..='z' => 2
          'λ' => 3
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LParen
      break
    }
    2 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Var
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
      self.lexeme.token = Lam
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [
      Var,
      Lam,
      LParen,
    ])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan1(self : Self) -> Lexeme raise LexerError {
  // [Var]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          'A'..='Z' => 1
          '_' => 1
          'a'..='z' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Var
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
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [Var])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan2(self : Self) -> Lexeme raise LexerError {
  // [LAURUS_EOF, Var, Lam, LParen]
  self.skip_space() |> ignore
  loop 0 {
    0 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LAURUS_EOF
      continue match self.next() {
          '(' => 1
          'A'..='Z' => 2
          '\\' => 3
          '_' => 2
          'a'..='z' => 2
          'λ' => 3
          _ => break
        }
    }
    1 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LParen
      break
    }
    2 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Var
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
      self.lexeme.token = Lam
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [
      LAURUS_EOF,
      Var,
      Lam,
      LParen,
    ])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan3(self : Self) -> Lexeme raise LexerError {
  // [Arr]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '-' => 1
          '→' => 2
          _ => break
        }
    1 =>
      continue match self.next() {
          '>' => 2
          _ => break
        }
    2 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Arr
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [Arr])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan4(self : Self) -> Lexeme raise LexerError {
  // [Var, Lam, LParen, RParen]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '(' => 1
          ')' => 2
          'A'..='Z' => 3
          '\\' => 4
          '_' => 3
          'a'..='z' => 3
          'λ' => 4
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LParen
      break
    }
    2 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = RParen
      break
    }
    3 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Var
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
      self.lexeme.token = Lam
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [
      Var,
      Lam,
      LParen,
      RParen,
    ])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}
