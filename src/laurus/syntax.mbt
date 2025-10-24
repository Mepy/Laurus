///|
struct Range(Char, Char) derive(Show, Eq)

///|
struct Rule {
  priority : Priority
  shift_reduce : ShiftReduce
  action : Action
  symbols : Array[Symbol]
} derive(Show, Eq)

///|
enum TokenConv {
  Ignore
  BuiltIn(String)
  Interpret(type_name~ : String, parse_func_name~ : String)
} derive(Show, Eq)

///|
enum RegExp {
  Union(RegExp, RegExp)
  Seq(RegExp, RegExp)
  Star(RegExp)
  Plus(RegExp)
  Ques(RegExp)
  Single(Char)
  Bor(Array[Range])
  Bnot(Array[Range])
  Emp
  Any
} derive(Show, Eq)

///|
enum SortType {
  Ignore
  Atom(String)
  Gen(String, Generics)
} derive(Show, Eq)

///|
enum Generics {
  Atom(String)
  Gen(String, Generics)
} derive(Show, Eq)

///|
enum Priority {
  Equal
  Higher
} derive(Show, Eq)

///|
enum ShiftReduce {
  Reduce
  Shift
} derive(Show, Eq)

///|
enum Action {
  Wrapper
  Constructor(String)
  Method(String)
} derive(Show, Eq)

///|
enum Symbol {
  Unnamed(String)
  Named(field_name~ : String, String)
  NamedAbbrev(field_name~ : String)
} derive(Show, Eq)
