///|
struct Lexeme {
  mut token : Token
  beg : Int
  mut end : Int
} derive(Show)

///|
fn Lexeme::new(beg? : Int = 0) -> Self {
  { token: 0, beg, end: 0 }
}

///|
struct Lexer {
  mut src : String
  mut cur : Int
  mut lexeme : Lexeme
} derive(Show)

///|
fn Lexer::new(src? : String = "") -> Self {
  { src, cur: -1, lexeme: Lexeme::new() }
}

///|
fn Lexer::init(self : Self, src : String, cur? : Int = -1) -> Unit {
  self.src = src
  self.cur = cur
}

///|
fn Lexer::get(self : Self, lexeme : Lexeme) -> String {
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
fn Lexer::scan0(self : Self) -> Lexeme {
  loop 0 {
    0 =>
      continue match self.next() {
          '\u{0}'..='\'' => 1
          '(' => 2
          '.' => 3
          '/'..='Z' => 1
          '[' => 4
          '\\' => 5
          '_'..='{' => 1
          '}'..='\u{10FFFF}' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = 2
      break
    }
    2 => {
      self.lexeme.end = self.cur
      self.lexeme.token = 12
      break
    }
    3 => {
      self.lexeme.end = self.cur
      self.lexeme.token = 6
      break
    }
    4 => {
      self.lexeme.end = self.cur
      self.lexeme.token = 14
      break
    }
    5 => {
      self.lexeme.end = self.cur
      self.lexeme.token = 1
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.lexeme = Lexeme::new(beg=lexeme.end + 1)
  lexeme
} ///|

///|
fn Lexer::scan1(self : Self) -> Lexeme {
  loop 0 {
    0 =>
      continue match self.next() {
          '('..='+' => 1
          '-'..='.' => 1
          '['..='^' => 1
          'n' => 2
          's'..='t' => 2
          'u' => 3
          '|' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = 3
      break
    }
    2 => {
      self.lexeme.end = self.cur
      self.lexeme.token = 4
      break
    }
    3 =>
      continue match self.next() {
          '0' => 4
          '1' => 5
          '2'..='9' => 4
          'A'..='F' => 4
          'a'..='f' => 4
          _ => break
        }
    4 => {
      self.lexeme.end = self.cur
      self.lexeme.token = 5
      continue match self.next() {
          '0'..='9' => 6
          'A'..='F' => 6
          'a'..='f' => 6
          _ => break
        }
    }
    5 => {
      self.lexeme.end = self.cur
      self.lexeme.token = 5
      continue match self.next() {
          '0' => 4
          '1'..='9' => 6
          'A'..='F' => 6
          'a'..='f' => 6
          _ => break
        }
    }
    6 => {
      self.lexeme.end = self.cur
      self.lexeme.token = 5
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.lexeme = Lexeme::new(beg=lexeme.end + 1)
  lexeme
} ///|

///|
fn Lexer::scan2(self : Self) -> Lexeme {
  loop 0 {
    0 =>
      continue match self.next() {
          '\u{0}'..='\'' => 1
          '(' => 2
          '*' => 3
          '+' => 4
          '.' => 5
          '/'..='Z' => 1
          '[' => 6
          '\\' => 7
          '_'..='{' => 1
          '|' => 8
          '}'..='\u{10FFFF}' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = 2
      break
    }
    2 => {
      self.lexeme.end = self.cur
      self.lexeme.token = 12
      break
    }
    3 => {
      self.lexeme.end = self.cur
      self.lexeme.token = 7
      break
    }
    4 => {
      self.lexeme.end = self.cur
      self.lexeme.token = 8
      break
    }
    5 => {
      self.lexeme.end = self.cur
      self.lexeme.token = 6
      break
    }
    6 => {
      self.lexeme.end = self.cur
      self.lexeme.token = 14
      break
    }
    7 => {
      self.lexeme.end = self.cur
      self.lexeme.token = 1
      break
    }
    8 => {
      self.lexeme.end = self.cur
      self.lexeme.token = 11
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.lexeme = Lexeme::new(beg=lexeme.end + 1)
  lexeme
}
