///|
struct TyA(String) derive(Show, Eq)

///|
struct TyS {
  a : TyA
  b : TyB
} derive(Show, Eq)

///|
enum TyB {
  One(String)
  Two(first~ : String, second~ : String)
} derive(Show, Eq)
