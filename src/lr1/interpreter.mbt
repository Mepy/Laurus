///|
struct Interpreter {} derive(Show)

///|
#inline
fn Interpreter::parseA(str : String) -> String {
  str
}

///|
#inline
fn Interpreter::parseB(str : String) -> String {
  str
}

///|
#inline
fn Interpreter::parseStart(s : TyS) -> TyS {
  println("\{s}")
  s
}
