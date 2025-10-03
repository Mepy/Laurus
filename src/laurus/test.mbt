///|
test "codegen::laurus" {
  let laurus = Laurus::new()
  let re_az = Bor([Range('a', 'z')])
  let re_AZ = Bor([Range('A', 'Z')])
  let re_azAZ = Bor([Range('A', 'Z')])
  let re_azAZ09_ = Bor([
    Range('a', 'z'),
    Range('A', 'Z'),
    Range('0', '9'),
    Range::single('_'),
  ])
  let lower = Seq(re_az, Star(re_azAZ09_))
  let upper = Seq(re_AZ, Star(re_azAZ09_))
  let ident = Seq(re_azAZ, Star(re_azAZ09_))
  let hex = Bor([Range('0', '9'), Range('a', 'f'), Range('A', 'F')])
  laurus
  // space token
  .set_space(
    Star(Bor([Range::single(' '), Range::single('\t'), Range::single('\t')])),
  )
  // name tokens
  .add_token("Symbol", BuiltIn("String"), ident)
  .add_token("TokenName", BuiltIn("String"), upper)
  .add_token("SortName", BuiltIn("String"), lower)
  .add_token("TypeName", BuiltIn("String"), upper)
  .add_token("MethodName", BuiltIn("String"), lower)
  .add_token("ConstructorName", BuiltIn("String"), upper)
  .add_token("FieldName", BuiltIn("String"), lower)
  // ignore tokens  
  .add_token(
    "Space",
    Ignore,
    Seq( // space
      Single('s'),
      Seq(Single('p'), Seq(Single('a'), Seq(Single('c'), Single('e')))),
    ),
  )
  .add_token(
    "Start",
    Ignore,
    Seq( // start
      Single('s'),
      Seq(Single('t'), Seq(Single('a'), Seq(Single('r'), Single('t')))),
    ),
  )
  .add_token(
    "Shift",
    Ignore,
    Seq(
      Single('@'),
      Union(
        Seq( // shift
          Single('s'),
          Seq(Single('h'), Seq(Single('i'), Seq(Single('f'), Single('t')))),
        ),
        Seq( // right
          Single('r'),
          Seq(Single('i'), Seq(Single('g'), Seq(Single('h'), Single('t')))),
        ),
      ),
    ),
  )
  .add_token(
    "Reduce",
    Ignore,
    Seq(
      Single('@'),
      Union(
        Seq( // reduce
          Single('r'),
          Seq(
            Single('e'),
            Seq(Single('d'), Seq(Single('u'), Seq(Single('c'), Single('e')))),
          ),
        ),
        Seq( // left
          Single('l'),
          Seq(Single('e'), Seq(Single('f'), Single('t'))),
        ),
      ),
    ),
  )
  .add_token("Percent", Ignore, Single('%'))
  .add_token("Eq", Ignore, Single('='))
  .add_token("Colon", Ignore, Single(':'))
  .add_token("ColonColon", Ignore, Seq(Single('%'), Single('%')))
  .add_token("Dot", Ignore, Single('.'))
  .add_token("Star", Ignore, Single('*'))
  .add_token("Plus", Ignore, Single('+'))
  .add_token("Ques", Ignore, Single('?'))
  .add_token("Dasg", Ignore, Single('-'))
  .add_token("Caret", Ignore, Single('^'))
  .add_token("Or", Ignore, Single('|'))
  .add_token("Tilde", Ignore, Single('~'))
  .add_token("LParen", Ignore, Single('('))
  .add_token("RParen", Ignore, Single(')'))
  .add_token("LBrack", Ignore, Single('['))
  .add_token("RBrack", Ignore, Single(']'))
  .add_token("LBrace", Ignore, Single('{'))
  .add_token("RBrace", Ignore, Single('}'))
  .add_token("Esc", Ignore, Single('\\'))
  .add_token("EscU", Ignore, Single('u'))
  // Char token
  .add_token(
    "EscNo",
    Conversion(type_name="Char", parse_func_name="get0"),
    Bnot([
      Range::single('\\'),
      Range::single('/'),
      Range::single('.'),
      Range::single('*'),
      Range::single('+'),
      Range::single('?'),
      Range::single('-'),
      Range::single('^'),
      Range::single('|'),
      Range::single('['),
      Range::single(']'),
      Range::single('('),
      Range::single(')'),
    ]),
  )
  .add_token(
    "EscOrigin",
    Conversion(type_name="Char", parse_func_name="get0"),
    Bor([
      Range::single('\\'),
      Range::single('/'),
      Range::single('.'),
      Range::single('*'),
      Range::single('+'),
      Range::single('?'),
      Range::single('-'),
      Range::single('^'),
      Range::single('|'),
      Range::single('['),
      Range::single(']'),
      Range::single('('),
      Range::single(')'),
    ]),
  )
  .add_token(
    "EscSpace",
    Conversion(type_name="Char", parse_func_name="esc_space"),
    Bor([Range::single('s'), Range::single('t'), Range::single('n')]),
  )
  .add_token(
    "EscUnicode",
    Conversion(type_name="Char", parse_func_name="esc_unicode"),
    Union(
      hex,
      Union(
        Seq(hex, hex),
        Union(
          Seq(hex, Seq(hex, hex)),
          Union(
            Seq(hex, Seq(hex, Seq(hex, hex))),
            Union(
              Seq(hex, Seq(hex, Seq(hex, Seq(hex, hex)))),
              Seq(
                Single('1'),
                Seq(Single('0'), Seq(hex, Seq(hex, Seq(hex, Seq(hex, hex))))),
              ),
            ),
          ),
        ),
      ),
    ),
  )
  // comment token
  .add_token("CommentHead", Ignore, Seq(Single('/'), Single('/')))
  .add_token(
    "CommentBody",
    BuiltIn("String"),
    Star(Bnot([Range::single('\n')])),
  )
  // sorts and rules
  .set_start("laurus")
  .add_sort("laurus", Atom("Laurus"), [
    Rule::eq_meth("new", []),
    Rule::eq_meth("add_comment", [
      Unnamed("laurus"),
      Unnamed("CommentHead"),
      Unnamed("CommentBody"),
    ]),
    Rule::eq_meth("set_space", [
      Unnamed("laurus"),
      Unnamed("Percent"),
      Unnamed("Space"),
      Unnamed("reg_exp"),
    ]),
    Rule::eq_meth("set_start", [
      Unnamed("laurus"),
      Unnamed("Percent"),
      Unnamed("Start"),
      Unnamed("SortName"),
    ]),
    Rule::eq_meth("add_token", [
      Unnamed("laurus"),
      Named(field_name="token_name", "TokenName"),
      NamedAbbrev(field_name="token_conv"),
      NamedAbbrev(field_name="reg_exp"),
    ]),
    Rule::eq_meth("add_sort", [
      Unnamed("laurus"),
      Named(field_name="sort_name", "SortName"),
      NamedAbbrev(field_name="sort_type"),
      NamedAbbrev(field_name="rules"),
    ]),
  ])
  // sorts of tokens
  .add_sort("token_conv", Atom("TokenConv"), [
    Rule::eq_Cons("Ignore", []),
    Rule::eq_Cons("Builtin", [Unnamed("TypeName")]),
    Rule::eq_Cons("Conversion", [
      Named(field_name="type_name", "TypeName"),
      Unnamed("ColonColon"),
      Named(field_name="parse_func_name", "MethodName"),
    ]),
  ])
  .add_sort("reg_exp", Atom("RegExp"), [
    Rule::eq_wrap([Unnamed("reg_exp")]),
    Rule::eq_Cons("Bor", [
      Unnamed("LBrack"),
      Unnamed("ranges"),
      Unnamed("RBrack"),
    ]),
    Rule::eq_Cons("Bnot", [
      Unnamed("LBrack"),
      Unnamed("Caret"),
      Unnamed("ranges"),
      Unnamed("RBrack"),
    ]),
    Rule::eq_Cons("Any", [Unnamed("Dot")]),
    Rule::eq_Cons("Emp", []),
    Rule::hi_Cons("Union", [
      Unnamed("reg_exp"),
      Unnamed("Or"),
      Unnamed("reg_exp"),
    ]),
    Rule::hi_Cons("Seq", [Unnamed("reg_exp"), Unnamed("reg_exp")]),
    Rule::hi_Cons("Star", [Unnamed("reg_exp"), Unnamed("Star")]),
    Rule::eq_Cons("Plus", [Unnamed("reg_exp"), Unnamed("Plus")]),
    Rule::eq_Cons("Ques", [Unnamed("reg_exp"), Unnamed("Ques")]),
    Rule::hi_Cons("Single", [Unnamed("char")]),
  ])
  .add_sort("ranges", Gen("Array", Atom("Range")), [
    Rule::eq_meth("singleton", [Unnamed("range")]),
    Rule::eq_meth("snoc", [Unnamed("ranges"), Unnamed("range")]),
  ])
  .add_sort("range", Atom("Range"), [
    Rule::eq_meth("single", [Unnamed("char")]),
    Rule::eq_wrap([Unnamed("char"), Unnamed("Dash"), Unnamed("char")]),
  ])
  .add_sort("char", Atom("Char"), [
    Rule::eq_wrap([Unnamed("EscNo")]),
    Rule::eq_wrap([Unnamed("Esc"), Unnamed("EscOrigin")]),
    Rule::eq_wrap([Unnamed("Esc"), Unnamed("EscSpace")]),
    Rule::eq_wrap([Unnamed("Esc"), Unnamed("EscU"), Unnamed("EscUnicode")]),
  ])
  // sorts of sorts
  .add_sort("sort_type", Atom("SortType"), [
    Rule::eq_Cons("Ignore", []),
    Rule::eq_Cons("Atom", [Unnamed("Colon"), Unnamed("TypeName")]),
    Rule::eq_Cons("Gen", [
      Unnamed("Colon"),
      Unnamed("TypeName"),
      Unnamed("LBrack"),
      Unnamed("generics"),
      Unnamed("RBrack"),
    ]),
  ])
  .add_sort("generics", Atom("Generics"), [
    Rule::eq_Cons("Atom", [Unnamed("TypeName")]),
    Rule::eq_Cons("Gen", [
      Unnamed("TypeName"),
      Unnamed("LBrack"),
      Unnamed("generics"),
      Unnamed("RBrack"),
    ]),
  ])
  .add_sort("rules", Gen("Array", Atom("Rule")), [
    Rule::eq_meth("empty", []),
    Rule::eq_meth("snoc", [Unnamed("rules"), Unnamed("rule")]),
  ])
  .add_sort("rule", Atom("Rule"), [
    Rule::eq_wrap([
      NamedAbbrev(field_name="priority"),
      NamedAbbrev(field_name="shift_reduce"),
      NamedAbbrev(field_name="action"),
      Unnamed("LParen"),
      NamedAbbrev(field_name="symbols"),
      Unnamed("RParen"),
    ]),
  ])
  .add_sort("priority", Atom("Priority"), [
    Rule::eq_Cons("Equal", [Unnamed("Eq")]),
    Rule::eq_Cons("Higher", [Unnamed("Or")]),
  ])
  .add_sort("shift_reduce", Atom("ShiftReduce"), [
    Rule::eq_Cons("Reduce", []),
    Rule::eq_Cons("Reduce", [Unnamed("Reduce")]),
    Rule::eq_Cons("Shift", [Unnamed("Shift")]),
  ])
  .add_sort("action", Atom("Action"), [
    Rule::eq_Cons("Wrapper", []),
    Rule::eq_Cons("Constructor", [Unnamed("ConstructorName")]),
    Rule::eq_Cons("Method", [Unnamed("MethodName")]),
  ])
  .add_sort("symbols", Gen("Array", Atom("Symbol")), [
    Rule::eq_meth("empty", []),
    Rule::eq_meth("snoc", [Unnamed("symbols"), Unnamed("symbol")]),
  ])
  .add_sort("symbol", Atom("Symbol"), [
    Rule::eq_Cons("Unnamed", [Unnamed("Symbol")]),
    Rule::eq_Cons("Named", [
      Unnamed("LBrack"),
      Named(field_name="field_name", "FieldName"),
      Unnamed("Colon"),
      Unnamed("Symbol"),
      Unnamed("RBrack"),
    ]),
    Rule::eq_Cons("NamedAbbrev", [
      Unnamed("LBrack"),
      Named(field_name="field_name", "FieldName"),
      Unnamed("Tilde"),
      Unnamed("RBrack"),
    ]),
  ])
  |> ignore
}

///|
#inline
fn Rule::eq_meth(method_name : String, symbols : Array[Symbol]) -> Rule {
  Rule::{
    priority: Equal,
    shift_reduce: Reduce,
    action: Method(method_name),
    symbols,
  }
}

///|
#inline
fn Rule::eq_Cons(constructor_name : String, symbols : Array[Symbol]) -> Rule {
  Rule::{
    priority: Equal,
    shift_reduce: Reduce,
    action: Constructor(constructor_name),
    symbols,
  }
}

///|
#inline
fn Rule::hi_Cons(constructor_name : String, symbols : Array[Symbol]) -> Rule {
  Rule::{
    priority: Higher,
    shift_reduce: Reduce,
    action: Constructor(constructor_name),
    symbols,
  }
}

///|
#inline
fn Rule::eq_wrap(symbols : Array[Symbol]) -> Rule {
  Rule::{ priority: Equal, shift_reduce: Reduce, action: Wrapper, symbols }
}
