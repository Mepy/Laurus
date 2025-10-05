///|
/// Lowering Laurus syntax into dfas, grammars, semantic actions and others
///

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

///|
fn Laurus::lex_gen(self : Self) -> @dfa.Generator {
  let len = self.token_names.length() + 2 // due to EOF and SPACE
  let names = Array::new(capacity=len)
  names.push(@dfa.LAURUS_RESERVED_EOF)
  names.push(@dfa.LAURUS_RESERVED_SPACE)
  for name in self.token_names {
    names.push(name)
  }
  let nfas : Array[@dfa.NFA] = Array::new(capacity=len)
  nfas.push(RegExp::Emp.to_token_nfa(0))
  nfas.push(self.space.to_token_nfa(1))
  for i in 2..<len { // due to EOF and SPACE
    let reg_exp = self.token_reg_exps[i - 2] // due to EOF and SPACE
    nfas.push(reg_exp.to_token_nfa(i))
  }
  @dfa.Generator::new(names, nfas)
}

///|
fn Laurus::workbench(self : Laurus) -> @lr1.Generator {
  // we assert sort_names.length() > 0, we will soon add a checker towards Laurus (TODO)

  let sort_len = self.sort_names.length() + 1 // + %start
  let token_len = self.token_names.length() + 2 // + EOF
  let len = sort_len + token_len
  let name_indices : Map[String, @lr1.Symbol] = Map::new(capacity=len)
  let start = if self.start != "" { self.start } else { self.sort_names[0] }
  name_indices["%start"] = 0
  for name in self.sort_names {
    name_indices[name] = name_indices.size()
  }
  name_indices[@dfa.LAURUS_RESERVED_EOF] = name_indices.size()
  name_indices[@dfa.LAURUS_RESERVED_SPACE] = name_indices.size()
  for name in self.token_names {
    name_indices[name] = name_indices.size()
  }
  let names = name_indices.keys().to_array()
  let rules : Array[Array[@lr1.Sentence]] = Array::new(capacity=sort_len)
  rules.push([[name_indices[start]]]) // %start -> start
  for sort_rules in self.sort_rules {
    let sort_rules : Array[@lr1.Sentence] = sort_rules.map(rule => {
      let sentence : @lr1.Sentence = rule.symbols.map(symbol => {
        let name = match symbol {
          Unnamed(name) => name
          Named(name, ..) => name
          NamedAbbrev(field_name~) => field_name
        }
        name_indices[name]
      })
      sentence
    })
    rules.push(sort_rules)
  }
  let grammar = @lr1.Grammar::{ rules, }
  let maker = @lr1.LR1Maker::new(grammar)
  maker.construct_states()
  let lr1 = maker.to_lr1()
  let lex_gen = self.lex_gen()
  let generator = @lr1.Generator::new(lex_gen)
  generator.codegen_lexer(lr1)
  //
  //
  let type_namespaces = Array::new(capacity=len)
  let type_names = Array::new(capacity=len)
  let type_constr_names = Array::new(capacity=len)
  // type_name(space)s of sorts
  let start_sort_type = self.sort_types[0]
  type_namespaces.push(start_sort_type.namespace()) // %start
  type_names.push(start_sort_type.name()) // %start
  type_constr_names.push(start_sort_type.constr_name()) // %start
  for sort_type in self.sort_types {
    type_namespaces.push(sort_type.namespace())
    type_names.push(sort_type.name())
    type_constr_names.push(sort_type.constr_name())
  }
  // type_name(space)s of tokens
  type_namespaces.push(None) // EOF
  type_names.push(None) // EOF
  type_constr_names.push(None) // EOF
  type_namespaces.push(None) // SPACE
  type_names.push(None) // SPACE
  type_constr_names.push(None) // SPACE
  for token_conv in self.token_convs {
    let type_name = token_conv.type_name()
    type_namespaces.push(type_name)
    type_names.push(type_name)
    type_constr_names.push(type_name)
  }
  let rule_semantics = Array::makei(sort_len, i => Array::new(
    capacity=grammar.rules[i].length(),
  ))
  rule_semantics[0].push(@lr1.RuleSemantics::Identity)
  let tuple_types : Map[String, @lr1.TupleType] = Map::new()
  let struct_types : Map[String, @lr1.StructType] = Map::new()
  let enum_types : Map[String, @lr1.EnumType] = Map::new()
  let interpret_funcs : Map[@lr1.InterpretFuncName, @lr1.InterpretFuncType] = Map::new()
  for sort_i in 0..<(sort_len - 1) {
    let type_namespace = type_namespaces[sort_i + 1] // %start
    let type_name = type_names[sort_i + 1] // %start
    let rule_semantic = rule_semantics[sort_i + 1] // % start
    for rule in self.sort_rules[sort_i] {
      let field_and_type_names = rule.symbols.filter_map(symbol => {
        let (field_name, symbol_name) = symbol.field_and_name()
        let index = name_indices[symbol_name]
        match type_names[index] {
          None => None
          Some(type_name) => Some((field_name, type_name))
        }
      })
      match rule.action {
        Constructor(constructor_name) => {
          // constructors should belong to one type_namespace
          guard type_namespace is Some(type_namespace) else { continue }
          enum_types.update(type_namespace, enum_type => match enum_type {
            None => {
              let branches : Map[String, @lr1.EnumBranch] = Map::new()
              branches[constructor_name] = @lr1.EnumBranch::new(
                field_and_type_names,
              )
              Some(@lr1.EnumType::new(branches))
            }
            Some(enum_type) => {
              enum_type.branches[constructor_name] = @lr1.EnumBranch::new(
                field_and_type_names,
              )
              Some(enum_type)
            }
          })
          rule_semantic.push(
            @lr1.RuleSemantics::Constructor(
              constructor_name,
              field_and_type_names.map(field_and_type_name => {
                let (field_name, _field_type_name) = field_and_type_name
                field_name
              }),
            ),
          )
        }
        Method(method_name) => {
          // constructors should belong to one type_namespace
          guard type_namespace is Some(type_namespace) else { continue }
          guard type_name is Some(type_name) else { continue }
          interpret_funcs[@lr1.InterpretFuncName::new(
            type_namespace, method_name,
          )] = @lr1.InterpretFuncType::new(field_and_type_names, type_name)
          rule_semantic.push(
            @lr1.RuleSemantics::Interpret(parse_func_name=method_name),
          )
        }
        Wrapper =>
          match field_and_type_names {
            [] => ()
            [(_field_name, field_type_name)] if Some(field_type_name) ==
              type_name => rule_semantic.push(@lr1.RuleSemantics::Identity)
            _ => {
              guard type_name is Some(type_name) else { continue }
              if field_and_type_names
                .iter()
                .all(field_and_type_names => match field_and_type_names {
                  (Some(_), _) => true
                  _ => false
                }) { // all field name
                struct_types[type_name] = @lr1.StructType::new(
                  field_and_type_names.map(field_and_type_name => {
                    guard field_and_type_name
                      is (Some(field_name), field_type_name)
                    (field_name, field_type_name)
                  }),
                )
                rule_semantic.push(
                  @lr1.RuleSemantics::Struct(
                    field_and_type_names.map(field_and_type_name => {
                      guard field_and_type_name
                        is (Some(field_name), _field_type_name)
                      field_name
                    }),
                  ),
                )
              } else {
                tuple_types[type_name] = @lr1.TupleType::new(
                  field_and_type_names.map(field_and_type_name => {
                    let (_field_name, field_type_name) = field_and_type_name
                    field_type_name
                  }),
                )
                rule_semantic.push(@lr1.RuleSemantics::Tuple)
              }
            }
          }
      }
    }
  }
  let tokens = Array::new(capacity=self.token_convs.length() + 2) // due to EOF SPACE
  tokens.push(@lr1.TokenSemantics::Lexeme)
  tokens.push(@lr1.TokenSemantics::Ignore)
  for token_conv in self.token_convs {
    let token_sem = match token_conv {
      Ignore => @lr1.TokenSemantics::Ignore
      BuiltIn("String") => @lr1.TokenSemantics::String
      BuiltIn("Lexeme") => @lr1.TokenSemantics::Lexeme
      BuiltIn(_) => @lr1.TokenSemantics::Ignore
      Interpret(type_name~, parse_func_name~) =>
        @lr1.TokenSemantics::Interpret(type_name~, parse_func_name~)
    }
    tokens.push(token_sem)
  }
  let sem = @lr1.Semantics::new(
    names, rule_semantics, tokens, type_namespaces, type_names, type_constr_names,
    tuple_types, struct_types, enum_types, interpret_funcs,
  )
  generator.codegen_syntax_type(sem)
  generator.codegen_node_type(sem)
  generator.codegen_interpret(sem)
  generator.codegen_parse(lr1, sem)
  generator
}

///|
fn RegExp::to_nfa_rev(self : RegExp) -> @dfa.NFA {
  match self {
    RegExp::Single(c) => @dfa.NFA::single(c)
    RegExp::Bor(arr) => @dfa.NFA::bor(arr.map(range => (range.0, range.1)))
    RegExp::Bnot(arr) => @dfa.NFA::bnot(arr.map(range => (range.0, range.1)))
    RegExp::Any => @dfa.NFA::any()
    RegExp::Emp => @dfa.NFA::emp()
    RegExp::Union(re1, re2) =>
      @dfa.NFA::union([re1.to_nfa_rev(), re2.to_nfa_rev()])
    RegExp::Seq(re1, re2) =>
      @dfa.NFA::seq_rev([re1.to_nfa_rev(), re2.to_nfa_rev()])
    RegExp::Star(re) => re.to_nfa_rev().star()
    RegExp::Plus(re) => re.to_nfa_rev().plus()
    RegExp::Ques(re) => re.to_nfa_rev().ques()
  }
}

///|
fn RegExp::to_token_nfa(self : RegExp, token : @dfa.Token) -> @dfa.NFA {
  let nfa_rev = self.to_nfa_rev()
  let maker = @dfa.DFAMaker::from_nfa(nfa_rev)
  let dfa_rev = maker.to_dfa()
  let nfa = dfa_rev.to_nfa_rev(token~)
  nfa
}

///|
fn SortType::namespace(self : Self) -> String? {
  match self {
    Ignore => None
    Atom(type_name) => Some(type_name)
    Gen(type_name, _gen_arg) => Some(type_name)
  }
}

///|
fn SortType::name(self : Self) -> String? {
  match self {
    Ignore => None
    Atom(type_name) => Some(type_name)
    Gen(type_name, gen_arg) => Some("\{type_name}[\{gen_arg.name()}]")
  }
}

///|
fn SortType::constr_name(self : Self) -> String? {
  match self {
    Ignore => None
    Atom(type_name) => Some(type_name)
    Gen(type_name, gen_arg) => Some("\{type_name}_LB_\{gen_arg.name()}_RB_")
  }
}

///|
fn Generics::name(self : Self) -> String {
  match self {
    Atom(type_name) => type_name
    Gen(type_name, gen) => "\{type_name}[\{gen.name()}]"
  }
}

///|
fn Generics::constr_name(self : Self) -> String {
  match self {
    Atom(type_name) => type_name
    Gen(type_name, gen) => "\{type_name}_LB_\{gen.name()}_RB_"
  }
}

///|
fn TokenConv::type_name(self : Self) -> String? {
  match self {
    Ignore => None
    BuiltIn(type_name) => Some(type_name)
    Interpret(type_name~, ..) => Some(type_name)
  }
}

///|
fn Symbol::field_and_name(self : Self) -> (String?, String) {
  match self {
    Unnamed(name) => (None, name)
    Named(field_name~, name) => (Some(field_name), name)
    NamedAbbrev(field_name~) => (Some(field_name), field_name)
  }
}
