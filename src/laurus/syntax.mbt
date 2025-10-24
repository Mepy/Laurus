///|
struct Range(Char, Char) derive(Show)

///|
struct Rule {
  priority : Priority
  shift_reduce : ShiftReduce
  action : Action
  symbols : Array[Symbol]
} derive(Show)

///|
enum TokenConv {
  Ignore
  BuiltIn(String)
  Interpret(type_name~ : String, parse_func_name~ : String)
} derive(Show)

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
} derive(Show)

///|
enum SortType {
  Ignore
  Atom(String)
  Gen(String, Generics)
} derive(Show)

///|
enum Generics {
  Atom(String)
  Gen(String, Generics)
} derive(Show)

///|
enum Priority {
  Equal
  Higher
} derive(Show)

///|
enum ShiftReduce {
  Reduce
  Shift
} derive(Show)

///|
enum Action {
  Wrapper
  Constructor(String)
  Method(String)
} derive(Show)

///|
enum Symbol {
  Unnamed(String)
  Named(field_name~ : String, String)
  NamedAbbrev(field_name~ : String)
} derive(Show)
