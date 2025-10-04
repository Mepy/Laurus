///|
/// Lowering Laurus syntax into dfas, grammars, semantic actions and others
///

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
fn Laurus::workbench(self : Laurus) -> Unit raise {
  // we assert sort_names.length() > 0, we will soon add a checker towards Laurus (TODO)

  let sort_len = self.sort_names.length() + 1 // + %start
  let token_len = self.token_names.length() + 1 // + EOF
  let name_indices : Map[String, @lr1.Symbol] = Map::new(
    capacity=sort_len + token_len,
  )
  let start = if self.start != "" { self.start } else { self.sort_names[0] }
  name_indices["%start"] = 0
  for name in self.sort_names {
    name_indices[name] = name_indices.size()
  }
  name_indices[@dfa.LAURUS_RESERVED_TOKEN_NAME] = name_indices.size()
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
  let token_names = names[sort_len:].to_array() // EOF, ...
  let nfas : Array[@dfa.NFA] = Array::new(capacity=token_len)
  nfas.push(RegExp::Emp.to_token_nfa(0))
  for i in 1..<token_len {
    let reg_exp = self.token_reg_exps[i - 1] // due to EOF
    nfas.push(reg_exp.to_token_nfa(i))
  }
  let lex_gen = @dfa.Generator::new(token_names, nfas)
  let generator = @lr1.Generator::new(lex_gen)
  generator.codegen_lexer(lr1)
  generator.lex_gen.save("./src/laurus")
}
