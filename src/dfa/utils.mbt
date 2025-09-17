///|
typealias Char as CodePoint

///|
const MinCodePoint = '\u{0}'

///|
const MaxCodePoint = '\u{10FFFF}'

///|
fn CodePoint::next(self : CodePoint) -> CodePoint {
  return (self.to_int() + 1).unsafe_to_char()
}

///|
fn CodePoint::prev(self : CodePoint) -> CodePoint {
  return (self.to_int() - 1).unsafe_to_char()
}

///|
typealias UInt as Token

///|
typealias Int as Index
