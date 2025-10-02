///|
struct TyS {
  a : TyA
  b : TyB
} derive(Show)

///|
struct TyA(String) derive(Show)

///|
enum TyB {
  One(String)
  Two(first~ : String, second~ : String)
} derive(Show)
