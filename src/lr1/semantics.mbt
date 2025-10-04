///|
pub(all) struct TupleType {
  field_type_names : Array[String]
} derive(Show)

///|
pub fn TupleType::new(field_type_names : Array[String]) -> Self {
  { field_type_names, }
}

///|
pub(all) struct StructType {
  field_and_type_names : Array[(String, String)]
} derive(Show)

///|
pub fn StructType::new(field_and_type_names : Array[(String, String)]) -> Self {
  { field_and_type_names, }
}

///|
pub(all) struct EnumBranch {
  field_and_type_names : Array[(String?, String)]
} derive(Show)

///|
pub fn EnumBranch::new(field_and_type_names : Array[(String?, String)]) -> Self {
  { field_and_type_names, }
}

///|
pub(all) struct EnumType {
  branches : Map[String, EnumBranch]
} derive(Show)

///|
pub fn EnumType::new(branches : Map[String, EnumBranch]) -> Self {
  { branches, }
}

///|
struct InterpretFuncName {
  type_namespace : String
  func_name : String
} derive(Show, Hash, Eq)

///|
struct InterpretFuncType {
  param_and_type_names : Array[(String?, String)]
  retype_name : String
} derive(Show, Hash, Eq)

///|
pub fn InterpretFuncName::new(
  type_namespace : String,
  func_name : String,
) -> Self {
  { type_namespace, func_name }
}

///|
pub fn InterpretFuncType::new(
  param_and_type_names : Array[(String?, String)],
  retype_name : String,
) -> Self {
  { param_and_type_names, retype_name }
}

///|
pub(all) enum RuleSemantics {
  Constructor(String, Array[String?]) // constructor_name, field_names
  Struct(Array[String]) // field_names
  Tuple
  Identity
  Interpret(parse_func_name~ : String)
} derive(Show)

///|
pub(all) enum TokenSemantics {
  Ignore
  Lexeme
  String
  Interpret(type_name~ : String, parse_func_name~ : String)
} derive(Show)

///|
struct Semantics {
  // names of sorts and tokens
  names : Array[String]
  rules : Array[Array[RuleSemantics]]
  tokens : Array[TokenSemantics]
  type_namespaces : Array[String?]
  type_names : Array[String?]
  type_constr_names : Array[String?]
  node_branches : Set[(String, String)] // Set[(type_constr_name, type_name)]
  tuple_types : Map[String, TupleType]
  struct_types : Map[String, StructType]
  enum_types : Map[String, EnumType]
  interpret_funcs : Map[InterpretFuncName, InterpretFuncType]
} derive(Show)

///|
pub fn Semantics::new(
  names : Array[String],
  rules : Array[Array[RuleSemantics]],
  tokens : Array[TokenSemantics],
  type_namespaces : Array[String?],
  type_names : Array[String?],
  type_constr_names : Array[String?],
  tuple_types : Map[String, TupleType],
  struct_types : Map[String, StructType],
  enum_types : Map[String, EnumType],
  interpret_funcs : Map[InterpretFuncName, InterpretFuncType],
) -> Self {
  let node_branches = Set::new()
  let type_len = type_names.length()
  for i in 0..<type_len {
    match (type_constr_names[i], type_names[i]) {
      (Some(constr_name), Some(name)) => node_branches.add((constr_name, name))
      _ => ()
    }
  }
  Semantics::{
    names,
    rules,
    tokens,
    type_namespaces,
    type_names,
    type_constr_names,
    node_branches,
    tuple_types,
    struct_types,
    enum_types,
    interpret_funcs,
  }
}
