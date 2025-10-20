///|
pub enum TOKEN {
  LAURUS_EOF
  LAURUS_SPACE
  FullMoon
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
  guard self.cur < self.src.length() else { -1 }
  let c = self.src[self.cur]
  match c {
    0xD800..=0xDBFF as lead => {
      let tail = self.src[self.cur + 1]
      self.cur += 2
      (((lead & 0x3FF) << 10) | (tail & 0x3FF)) + 0x10000
    }
    _ as c => {
      self.cur += 1
      c
    }
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
  // [FullMoon]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '🌕' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = FullMoon
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
  // [LAURUS_EOF]
  self.skip_space() |> ignore
  loop 0 {
    0 => {
      self.lexeme.end = self.cur
      self.lexeme.token = LAURUS_EOF
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
}
