///|
const LAURUS_RESERVED_TOKEN_NAME : String = "LAURUS"

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
typealias Int as Token

///|
struct TokenSet(Set[Token]) derive(Show, Eq)

///|
suberror TokenConflicts Set[TokenSet]

///|
impl Hash for TokenSet with hash_combine(self : TokenSet, hasher : Hasher) {
  hasher.combine(self.hash())
}

///|
impl Hash for TokenSet with hash(self : TokenSet) -> Int {
  let s = self.0.to_array()
  s.sort()
  s.hash()
}

///|
typealias Int as Index

///|
struct Subset(Set[Index]) derive(Show, Eq)

///|
impl Hash for Subset with hash_combine(self : Subset, hasher : Hasher) {
  hasher.combine(self.hash())
}

///|
impl Hash for Subset with hash(self : Subset) -> Int {
  let s = self.0.to_array()
  s.sort()
  s.hash()
}
