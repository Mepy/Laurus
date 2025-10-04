///|
struct TyA(String) derive(Show)

///|
struct TyS {
  a : TyA
  b : TyB
} derive(Show)

///|
enum TyB {
  One(String)
  Two(first~ : String, second~ : String)
} derive(Show)
