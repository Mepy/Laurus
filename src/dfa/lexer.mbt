///|
struct Lexer {
  src : String
  mut token : Token
  mut cur : Int
  mut beg : Int
  mut end : Int
} derive(Show)

///|
fn Lexer::new(src : String) -> Self {
  Lexer::{ src, token: 0, cur: -1, beg: 0, end: 0 }
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
fn Lexer::scan(self : Self) -> (Token, Int, Int)? {
  loop 0 {
    0 =>
      continue match self.next() {
          'p'..='p' => 1
          _ => break
        }
    1 =>
      continue match self.next() {
          'l'..='l' => 2
          'r'..='r' => 3
          _ => break
        }
    2 =>
      continue match self.next() {
          'a'..='a' => 6
          _ => break
        }
    3 =>
      continue match self.next() {
          'a'..='a' => 4
          _ => break
        }
    4 =>
      continue match self.next() {
          'y'..='y' => 5
          _ => break
        }
    5 => {
      self.end = self.cur
      self.token = 2
      continue match self.next() {
          _ => break
        }
    }
    6 =>
      continue match self.next() {
          'y'..='y' => 7
          _ => break
        }
    7 => {
      self.end = self.cur
      self.token = 1
      continue match self.next() {
          _ => break
        }
    }
    _ => break
  }
  if self.token == 0 {
    None
  } else {
    let lexeme = Some((self.token, self.beg, self.end))
    self.beg = self.end + 1
    lexeme
  }
}

///|
test "Lexer::scan" {
  // Test successful recognition of "play" (token 1)
  let lexer1 = Lexer::new("play")
  inspect(lexer1.scan(), content="Some((1, 0, 3))")

  // Test successful recognition of "pray" (token 2)
  let lexer2 = Lexer::new("pray")
  inspect(lexer2.scan(), content="Some((2, 0, 3))")

  // Test partial match that fails
  let lexer3 = Lexer::new("pr")
  inspect(lexer3.scan(), content="None")
}

///|
test "Lexer::scan/boundary_cases" {
  // Test empty string
  let lexer1 = Lexer::new("")
  inspect(lexer1.scan(), content="None")

  // Test single character that doesn't match
  let lexer2 = Lexer::new("x")
  inspect(lexer2.scan(), content="None")

  // Test string that starts correctly but diverges
  let lexer3 = Lexer::new("plx")
  inspect(lexer3.scan(), content="None")

  // Test string longer than expected tokens
  let lexer4 = Lexer::new("playful")
  inspect(lexer4.scan(), content="Some((1, 0, 3))")
}

///|
test "Lexer::scan/prefix_disambiguation" {
  // Test that "pra" doesn't match either token
  let lexer1 = Lexer::new("pra")
  inspect(lexer1.scan(), content="None")

  // Test that "pl" doesn't match
  let lexer2 = Lexer::new("pl")
  inspect(lexer2.scan(), content="None")

  // Test that "p" alone doesn't match
  let lexer3 = Lexer::new("p")
  inspect(lexer3.scan(), content="None")
}
