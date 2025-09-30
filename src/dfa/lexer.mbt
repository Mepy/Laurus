///|
enum TOKEN {
  LAURUS
  PLAY
  PRAY
} derive(Show)

///|
struct Lexeme {
  mut token : TOKEN
  beg : Int
  mut end : Int
} derive(Show)

///|
fn Lexeme::new(beg? : Int = 0) -> Self {
  { token: LAURUS, beg, end: 0 }
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
          'p' => 1
          _ => break
        }
    1 =>
      continue match self.next() {
          'l' => 2
          'r' => 3
          _ => break
        }
    2 =>
      continue match self.next() {
          'a' => 6
          _ => break
        }
    3 =>
      continue match self.next() {
          'a' => 4
          _ => break
        }
    4 =>
      continue match self.next() {
          'y' => 5
          _ => break
        }
    5 => {
      self.lexeme.end = self.cur
      self.lexeme.token = PRAY
      break
    }
    6 =>
      continue match self.next() {
          'y' => 7
          _ => break
        }
    7 => {
      self.lexeme.end = self.cur
      self.lexeme.token = PLAY
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.lexeme = Lexeme::new(beg=lexeme.end + 1)
  lexeme
}
