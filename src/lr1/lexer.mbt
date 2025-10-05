///|
pub enum TOKEN {
  LAURUS_EOF
  LAURUS_SPACE
  A
  B
  C
  D
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
  // [A]
  self.skip_space() |> ignore
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
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan1(self : Self) -> Lexeme {
  // [B, D]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          'b' => 1
          'd' => 2
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = B
      break
    }
    2 => {
      self.lexeme.end = self.cur
      self.lexeme.token = D
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
  // [LAURUS_EOF, C]
  self.skip_space() |> ignore
  loop 0 {
    0 => {
      self.lexeme.end = self.cur
      self.lexeme.token = LAURUS_EOF
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
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan3(self : Self) -> Lexeme {
  // [B]
  self.skip_space() |> ignore
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
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
} ///|

///|
pub fn Lexer::scan4(self : Self) -> Lexeme {
  // [C, D]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          'c' => 1
          'd' => 2
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = C
      break
    }
    2 => {
      self.lexeme.end = self.cur
      self.lexeme.token = D
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
pub fn Lexer::scan5(self : Self) -> Lexeme {
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
} ///|

///|
pub fn Lexer::scan6(self : Self) -> Lexeme {
  // [D]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          'd' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur
      self.lexeme.token = D
      break
    }
    _ => break
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end
  self.lexeme = Lexeme::new(beg=lexeme.end)
  lexeme
}
