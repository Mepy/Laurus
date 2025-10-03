///|
const INGORED_TYPE_NAME : String = "Unit"

///|
const SEMANTIC_FUNC_PREFIX : String = "Interpreter::"

///|
const IDENTITY_TYPE_NAME : String = "String"

///|
const IDENTITY_FUNC_NAME : String = ""

///|
enum SortTag {
  EnumType
  TupleType
  StructType
  AsType
} derive(Show)

///|
struct SortSemantics {
  tag : SortTag
  type_name : String
} derive(Show)

///|
enum RuleSemantics {
  Constructor(String)
  NamedConstructor(String, field_names~ : Array[String])
  Tuple
  Fields(Array[String])
  Reduction(parse_func_name~ : String, parse_parameter_names~ : Array[String])
} derive(Show)

///|
pub(all) enum TokenSemantics {
  Ignore
  BuiltIn(String)
  Conversion(type_name~ : String, parse_func_name~ : String)
} derive(Show)

///|
struct Semantics {
  // names of sorts and tokens
  names : Array[String]
  sorts : Array[SortSemantics]
  rules : Array[Array[RuleSemantics]]
  tokens : Array[TokenSemantics]
  type_names : Array[String]
} derive(Show)

///|
fn Semantics::new(
  names : Array[String],
  sorts : Array[SortSemantics],
  rules : Array[Array[RuleSemantics]],
  tokens : Array[TokenSemantics],
) -> Self {
  let type_names = Array::new(capacity=names.length())
  let sort_len = sorts.length()
  for sort in 0..<sort_len {
    type_names.push(sorts[sort].type_name)
  }
  for token in 0..<tokens.length() {
    let type_name = match tokens[token] {
      Ignore => INGORED_TYPE_NAME
      BuiltIn(type_name) => type_name
      Conversion(type_name~, ..) => type_name
    }
    type_names.push(type_name)
  }
  Semantics::{ names, sorts, rules, tokens, type_names }
}

///|
#inline
fn Semantics::is_ignored(type_name : String) -> Bool {
  type_name == INGORED_TYPE_NAME
}

///|
#inline
fn Semantics::is_NOT_ignored(type_name : String) -> Bool {
  type_name != INGORED_TYPE_NAME
}

///|
#inline
fn Semantics::is_identity(type_name : String) -> Bool {
  type_name == IDENTITY_TYPE_NAME
}

///|
#inline
fn Semantics::is_identity_func_name(func_name : String) -> Bool {
  func_name == IDENTITY_FUNC_NAME
}
