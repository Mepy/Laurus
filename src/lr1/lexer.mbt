///|
pub enum TOKEN {
  LAURUS
  A
  B
  C
} derive(Show)

///|
pub struct Lexeme {
  mut token : TOKEN
  mut beg : Int
  mut end : Int
} derive(Show)

///|
fn Lexeme::new(beg? : Int = 0) -> Self {
  { token: LAURUS, beg, end: 0 }
}

///|
fn Lexeme::init(self : Self) -> Unit {
  self.token = LAURUS
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
  { src, cur: -1, lexeme: Lexeme::new() }
}

///|
pub fn Lexer::init(self : Self, src : String, cur? : Int = -1) -> Unit {
  self.src = src
  self.cur = cur
  self.lexeme.init()
}

///|
pub fn Lexer::get(self : Self, lexeme : Lexeme) -> String {
  let beg = lexeme.beg
  let end = lexeme.end
  self.src.unsafe_substring(start=beg, end=end + 1)
}

///|
fn Lexer::next(self : Self) -> Int {
  self.cur += 1
  if self.cur < self.src.length() {
    self.src[self.cur]
  } else {
    -1
  }
}

///|
pub fn Lexer::scan0(self : Self) -> Lexeme {
  // [A]
  loop 0 {
    0 =>
      continue match self.next() {
          'a' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = A
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.lexeme = Lexeme::new(beg=lexeme.end + 1)
  lexeme
} ///|

///|
pub fn Lexer::scan1(self : Self) -> Lexeme {
  // [B]
  loop 0 {
    0 =>
      continue match self.next() {
          'b' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = B
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.lexeme = Lexeme::new(beg=lexeme.end + 1)
  lexeme
} ///|

///|
pub fn Lexer::scan2(self : Self) -> Lexeme {
  // [LAURUS, C]
  loop 0 {
    0 => {
      self.lexeme.end = self.cur
      self.lexeme.token = LAURUS
      continue match self.next() {
          'c' => 1
          _ => break
        }
    }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = C
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.lexeme = Lexeme::new(beg=lexeme.end + 1)
  lexeme
} ///|

///|
pub fn Lexer::scan3(self : Self) -> Lexeme {
  // [LAURUS]
  loop 0 {
    0 => {
      self.lexeme.end = self.cur
      self.lexeme.token = LAURUS
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.lexeme = Lexeme::new(beg=lexeme.end + 1)
  lexeme
}
