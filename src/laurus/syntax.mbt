///|
enum RegExp {
  Bor(Array[Range])
  Bnot(Array[Range])
  Any
  Emp
  Union(RegExp, RegExp)
  Seq(RegExp, RegExp)
  Star(RegExp)
  Plus(RegExp)
  Ques(RegExp)
  Single(Char)
} derive(Show)

///|
typealias @lr1.TokenSemantics as TokenConv

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
} derive(Show, Eq)

///|
struct Rule {
  priority : Priority
  shift_reduce : ShiftReduce
  action : Action
  symbols : Array[Symbol]
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

///|
struct Range(Char, Char) derive(Show)

///|
struct Laurus {
  comments : Array[String]
  mut space : RegExp
  mut start : String
  token_names : Array[String]
  token_convs : Array[TokenConv]
  token_reg_exps : Array[RegExp]
  sort_names : Array[String]
  sort_types : Array[SortType]
  sort_rules : Array[Array[Rule]]
} derive(Show)
