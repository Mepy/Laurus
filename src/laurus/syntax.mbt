///|
pub(all) struct Range(Char, Char) derive(Show)

///|
pub(all) struct Rule {
  priority : Priority
  shift_reduce : ShiftReduce
  action : Action
  symbols : Array[Symbol]
} derive(Show)

///|
pub(all) enum TokenConv {
  Ignore
  BuiltIn(String)
  Interpret(type_name~ : String, parse_func_name~ : String)
} derive(Show)

///|
pub(all) enum RegExp {
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
pub(all) enum SortType {
  Ignore
  Atom(String)
  Gen(String, Generics)
} derive(Show)

///|
pub(all) enum Generics {
  Atom(String)
  Gen(String, Generics)
} derive(Show)

///|
pub(all) enum Priority {
  Equal
  Higher
} derive(Show)

///|
pub(all) enum ShiftReduce {
  Reduce
  Shift
} derive(Show)

///|
pub(all) enum Action {
  Wrapper
  Constructor(String)
  Method(String)
} derive(Show)

///|
pub(all) enum Symbol {
  Unnamed(String)
  Named(field_name~ : String, String)
  NamedAbbrev(field_name~ : String)
} derive(Show)
