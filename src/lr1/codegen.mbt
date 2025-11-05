///|
pub(all) struct Generator {
  builder : StringBuilder
  syntax_builder : StringBuilder
  interpreter_builder : StringBuilder
  lex_gen : @dfa.Generator
} derive(Show)

///|
pub fn Generator::new(lex_gen : @dfa.Generator) -> Self {
  let builder = StringBuilder::new()
  let syntax_builder = StringBuilder::new()
  let interpreter_builder = StringBuilder::new()
  let generator = { builder, syntax_builder, interpreter_builder, lex_gen }
  generator.init()
  generator
}

///|
fn Generator::init(self : Self) -> Unit {
  let parser =
    #|///|
    #|pub struct Span {  
    #|  beg : Location
    #|  end : Location
    #|  children : FixedArray[Span]
    #|} derive(Show)
    #|
    #|///|
    #|#inline
    #|fn Span::leaf(beg : Location, end : Location) -> Span {
    #|  {beg, end, children : FixedArray::default() }
    #|}
    #|
    #|///|
    #|fn Span::tree(children : FixedArray[Span]) -> Span {
    #|  let len = children.length()
    #|  // guard len != 0
    #|  let beg = children[0].beg
    #|  let end = children[len - 1].end
    #|  { beg, end, children }
    #|}
    #|
    #|///|
    #|struct Parser {
    #|  lexer : Lexer
    #|  state_stack : Array[Int]
    #|  span_stack : Array[Span]
    #|  node_stack : Array[Node]
    #|} derive(Show)
    #|
    #|///|
    #|pub fn Parser::new(src? : String = "") -> Self {
    #|  {
    #|    lexer: Lexer::new(src~),
    #|    state_stack: Array::new(),
    #|    span_stack: Array::new(),
    #|    node_stack: Array::new(),
    #|  }
    #|}
    #|
    #|///|
    #|pub fn Parser::init(self : Self, src : String, cur? : Location = Location::default()) -> Unit {
    #|  self.lexer.init(src, cur~)
    #|  self.state_stack.clear()
    #|  self.node_stack.clear()
    #|}
    #|
    #|///|
    #|#inline
    #|fn Parser::shift_span(self : Self, lexeme : Lexeme) -> Unit {
    #|  // no need to clone lexeme.beg/end because it is to be consumed.
    #|  self.span_stack.push(Span::leaf(lexeme.beg, lexeme.end))
    #|}
    #|
    #|///|
    #|#inline
    #|fn Parser::enter_state(self : Self, state_i : Int) -> Unit {
    #|  self.state_stack.push(state_i)
    #|}
    #|
  self.builder.write_string(parser)
}

///|
pub fn Generator::codegen_syntax_type(self : Self, sem : Semantics) -> Unit {
  for named_tuple_type in sem.tuple_types {
    let (type_name, { field_type_names }) = named_tuple_type
    let type_header =
      #|///|
      $|pub(all) struct \{type_name} (
    let type_footer =
      #|) derive(Show)
      #|
    self.syntax_builder.write_string(type_header)
    for field_type_name in field_type_names {
      self.syntax_builder.write_string("\{field_type_name}, ")
    }
    self.syntax_builder.write_string(type_footer)
  }
  for named_struct_type in sem.struct_types {
    let (type_name, { field_and_type_names }) = named_struct_type
    let type_header =
      #|///|
      $|pub(all) struct \{type_name} {
      $|
    let type_footer =
      #|} derive(Show)
      #|
    self.syntax_builder.write_string(type_header)
    for field_and_type_name in field_and_type_names {
      let (field_name, type_name) = field_and_type_name
      self.syntax_builder.write_string("\t\{field_name} : \{type_name}\n")
    }
    self.syntax_builder.write_string(type_footer)
  }
  for named_enum_type in sem.enum_types {
    let (type_name, { branches }) = named_enum_type
    let type_header =
      #|///|
      $|pub(all) enum \{type_name} {
      $|
    let type_footer =
      #|} derive(Show)
      #|
    self.syntax_builder.write_string(type_header)
    for branch in branches {
      let (branch_name, { field_and_type_names }) = branch
      if field_and_type_names.length() == 0 {
        self.syntax_builder.write_string("\t\{branch_name}\n")
      } else {
        self.syntax_builder.write_string("\t\{branch_name}(")
        for field_and_type_name in field_and_type_names {
          match field_and_type_name {
            (None, type_name) =>
              self.syntax_builder.write_string("\{type_name}, ")
            (Some(field_name), type_name) =>
              self.syntax_builder.write_string(
                "\{field_name}~ : \{type_name}, ",
              )
          }
        }
        self.syntax_builder.write_string(")\n")
      }
    }
    self.syntax_builder.write_string(type_footer)
  }
}

///|
pub fn Generator::codegen_node_type(self : Self, sem : Semantics) -> Unit {
  let node_header =
    #|///|
    #|enum Node {
    #|
  let node_footer =
    #|} derive(Show)
    #|
  self.builder.write_string(node_header)
  for branch in sem.node_branches {
    let (type_constr_name, type_name) = branch
    self.builder.write_string("  \{type_constr_name}(\{type_name})\n")
  }
  self.builder.write_string(node_footer)
}

///|
pub fn Generator::codegen_interpret(self : Self, sem : Semantics) -> Unit {
  for interp in sem.interpret_funcs {
    let (interp_name, interp_type) = interp
    let interpret_func_header =
      #|///|
      #|#inline
      $|fn\{interp_type.generic_param} \{interp_name.type_namespace}::\{interp_name.func_name}(
    let interpret_func_footer =
      $|) -> \{interp_type.retype_name} { ... }
      #|
    self.interpreter_builder.write_string(interpret_func_header)
    let param_len = interp_type.param_and_type_names.length()
    for i in 0..<param_len {
      match interp_type.param_and_type_names[i] {
        (Some(param_name), type_name) =>
          self.interpreter_builder.write_string(
            "\{param_name} : \{type_name}, ",
          )
        (None, type_name) =>
          self.interpreter_builder.write_string("_\{i} : \{type_name}, ")
      }
    }
    self.interpreter_builder.write_string(interpret_func_footer)
  }
}

///|
pub fn Generator::codegen_lexer(self : Self, lr1 : LR1) -> Unit {
  // codegen dfas
  for dfa_token in lr1.dfa_tokens {
    self.lex_gen.codegen_scan(dfa_token)
  }
}

///|
pub fn Generator::codegen_parse(
  self : Self,
  lr1 : LR1,
  sem : Semantics,
) -> Unit {
  let parse_header =
    #|///|
    $|pub fn Parser::parse(self : Self) -> \{sem.type_names[0].unwrap()} raise LexerError {
    #|  let mut lexeme = self.lexer.scan0()
    #|  loop 0 {
    #|
  let parse_footer =
    #|    _ => break
    #|  }
    $|	guard self.node_stack[0] is \{sem.type_constr_names[0].unwrap()}(node)
    #|  node
    #|}
    #|
  self.builder.write_string(parse_header)
  let state_len = lr1.states.length()
  for state_i in 0..<state_len {
    self.builder.write_string("    \{state_i} => {\n")
    self.builder.write_string("      self.enter_state(\{state_i})\n")
    // codegen LR1 items
    for item in lr1.states[state_i] {
      self.builder.write_string("      // \{sem.names[item.sort]} ->") // indent
      let sentence_len = item.sentence.length()
      for i in 0..<item.cur {
        self.builder.write_string(" \{sem.names[item.sentence[i]]}")
      }
      self.builder.write_string(" ●")
      for i in item.cur..<sentence_len {
        self.builder.write_string(" \{sem.names[item.sentence[i]]}")
      }
      self.builder.write_string(" | \{sem.names[item.lookahead]}\n")
    }
    self.builder.write_string("      continue match lexeme.token {\n")
    let shift_map = lr1.shift_table[state_i]
    let reduce_map = lr1.reduce_table[state_i]

    // let alt_shift_map : Map[StateIndex, (Index, Array[Token])] = Map::new()
    // for token_state_dfa in shift_map {
    //   let (token, (state_j, dfa_j)) = token_state_dfa
    //   alt_shift_map.get_or_init(state_j, fn(){(dfa_j, Array::new())}).1.push(token)
    // }
    let alt_reduce_map : Map[(Sort, RuleIndex), (RuleSize, Array[Token])] = Map::new()
    for token_sort_rule_i_size in reduce_map {
      let (token, (sort, rule_i, rule_size)) = token_sort_rule_i_size
      alt_reduce_map.get_or_init((sort, rule_i), fn() {
        (rule_size, Array::new())
      }).1.push(token)
    }
    // codegen shift
    for token_state_dfa in shift_map {
      let (token, (state_j, dfa_j)) = token_state_dfa
      let token_name = sem.names[token]
      let shift_header =
        $|          \{token_name} => { // shift
        #|
      let shift_footer =
        $|            self.shift_span(lexeme)
        $|            lexeme = self.lexer.scan\{dfa_j}()
        $|            \{state_j}
        #|          }
        #|
      self.builder.write_string(shift_header)
      // token - lr1.sort_len !!!
      match sem.tokens[token - lr1.sort_len] {
        Ignore =>
          self.builder.write_string("            // ignore the old lexeme\n")
        Lexeme =>
          self.builder.write_string(
            "            self.node_stack.push(Node::Lexeme(lexeme))\n",
          )
        String => {
          let shift_node =
            $|            let node = self.lexer.get(lexeme) |> Node::String
            $|            self.node_stack.push(node)
            $|
          self.builder.write_string(shift_node)
        }
        Interpret(type_name~, parse_func_name~) => {
          let shift_node =
            $|            let node = self.lexer.get(lexeme) |> \{type_name}::\{parse_func_name} |> Node::\{type_name}
            $|            self.node_stack.push(node)
            $|
          self.builder.write_string(shift_node)
        }
      }
      self.builder.write_string(shift_footer)
    }

    // codegen reduce
    for sort_rule_i_size_tokens in alt_reduce_map {
      let ((sort, rule_i), (rule_size, tokens)) = sort_rule_i_size_tokens
      let tokens_name = tokens.map(token => sem.names[token]).join(" | ")
      let reduce_header =
        $|          \{tokens_name} => { // reduce
        $|
      let reduce_footer =
        #|          }
        #|
      self.builder.write_string(reduce_header)
      if rule_size == 0 {
        let span_code =
          $|            let loc = self.lexer.cur_loc()
          $|						let span = Span::leaf(loc, loc)
          $|
        self.builder.write_string(span_code)
      } else {
        let span_code =
          $|            let span = self.span_stack[self.span_stack.length()-\{rule_size}:].iter() |> FixedArray::from_iter |> Span::tree
          $|
        self.builder.write_string(span_code)
      }
      // pop state_stack, span_stack
      for i in 0..<rule_size {
        let pop_stack =
          #|            self.state_stack.unsafe_pop() |> ignore
          #|            self.span_stack.unsafe_pop() |> ignore
          #|
        self.builder.write_string(pop_stack)
      }
      self.builder.write_string("            self.span_stack.push(span)\n")

      // pop node_stack
      for i = rule_size - 1; i >= 0; i = i - 1 {
        let symbol = lr1.grammar.rules[sort][rule_i][i]
        match sem.type_constr_names[symbol] {
          None =>
            self.builder.write_string(
              "            // ignore Node [x\{i} : \{sem.names[symbol]}]\n",
            )
          Some(type_constr_name) =>
            self.builder.write_string(
              "            guard self.node_stack.unsafe_pop() is Node::\{type_constr_name}(x\{i})\n",
            )
        }
      }
      // construct new node according to the semantics of the rule
      match (sem.type_namespaces[sort], sem.type_constr_names[sort]) {
        (Some(type_namespace), Some(type_constr_name)) => {
          match sem.rules[sort][rule_i] {
            Constructor(constructor_name, field_names) => {
              let no_arg = lr1.grammar.rules[sort][rule_i]
                .iter()
                .all(symbol => match sem.type_names[symbol] {
                  None => true
                  _ => false
                })
              if no_arg {
                self.builder.write_string(
                  "            let node = \{type_namespace}::\{constructor_name} |> Node::\{type_constr_name}\n",
                )
              } else {
                self.builder.write_string(
                  "            let node = \{type_namespace}::\{constructor_name}(",
                )
                let mut ignore_offset = 0
                for i in 0..<rule_size {
                  let type_name = sem.type_names[lr1.grammar.rules[sort][rule_i][i]]
                  guard type_name is Some(_) else { ignore_offset += 1 }
                  match field_names[i - ignore_offset] {
                    None => self.builder.write_string("x\{i}, ")
                    Some(field_name) =>
                      self.builder.write_string("\{field_name} = x\{i}, ")
                  }
                }
                self.builder.write_string(") |> Node::\{type_constr_name}\n")
              }
            }
            Struct(field_names) => {
              self.builder.write_string(
                "            let node = \{type_namespace}::{",
              )
              let mut ignore_offset = 0
              for i in 0..<rule_size {
                let type_name = sem.type_names[lr1.grammar.rules[sort][rule_i][i]]
                guard type_name is Some(_) else { ignore_offset += 1 }
                let field_name = field_names[i - ignore_offset]
                self.builder.write_string("\{field_name} : x\{i}, ")
              }
              self.builder.write_string("} |> Node::\{type_constr_name}\n")
            }
            Tuple => {
              self.builder.write_string(
                "            let node = \{type_namespace}(",
              )
              for i in 0..<rule_size {
                let type_name = sem.type_names[lr1.grammar.rules[sort][rule_i][i]]
                guard type_name is Some(_) else { continue }
                self.builder.write_string("x\{i}, ")
              }
              self.builder.write_string(") |> Node::\{type_constr_name}\n")
            }
            Identity => {
              self.builder.write_string("            let node = (")
              for i in 0..<rule_size {
                let type_name = sem.type_names[lr1.grammar.rules[sort][rule_i][i]]
                guard type_name is Some(_) else { continue }
                self.builder.write_string("x\{i}, ")
              }
              self.builder.write_string(") |> Node::\{type_constr_name}\n")
            }
            Interpret(parse_func_name~) => {
              self.builder.write_string(
                "            let node = \{type_namespace}::\{parse_func_name}(",
              )
              for i in 0..<rule_size {
                let type_name = sem.type_names[lr1.grammar.rules[sort][rule_i][i]]
                guard type_name is Some(_) else { continue }
                self.builder.write_string("x\{i}, ")
              }
              self.builder.write_string(") |> Node::\{type_constr_name}\n")
            }
          }
          // match sem.rules[sort][rule_i] {
          //   Constructor(constructor_name) => {
          //     self.builder.write_string(
          //       "            let node = \{constructor_name}(",
          //     )
          //     for i in 0..<rule_size {
          //       let type_name = sem.type_names[lr1.grammar.rules[sort][rule_i][i]]
          //       if Semantics::is_NOT_ignored(type_name) {
          //         self.builder.write_string("x\{i}, ")
          //       }
          //     }
          //     self.builder.write_string(") |> Node::\{type_name}\n")
          //   }
          //   NamedConstructor(constructor_name, field_names~) => {
          //     self.builder.write_string(
          //       "            let node = \{constructor_name}(",
          //     )
          //     let mut ignore_offset = 0
          //     for i in 0..<rule_size {
          //       let type_name = sem.type_names[lr1.grammar.rules[sort][rule_i][i]]
          //       if Semantics::is_ignored(type_name) {
          //         ignore_offset += 1
          //       } else {
          //         self.builder.write_string(
          //           "\{field_names[i - ignore_offset]} = x\{i}, ",
          //         )
          //       }
          //     }
          //     self.builder.write_string(") |> Node::\{type_name}\n")
          //   }
          //   Tuple => {
          //     self.builder.write_string("            let node = \{type_name}(")
          //     for i in 0..<rule_size {
          //       let type_name = sem.type_names[lr1.grammar.rules[sort][rule_i][i]]
          //       if Semantics::is_NOT_ignored(type_name) {
          //         self.builder.write_string("x\{i}, ")
          //       }
          //     }
          //     self.builder.write_string(") |> Node::\{type_name}\n")
          //   }
          //   Fields(field_names) => {
          //     self.builder.write_string(
          //       "            let node = \{type_name}::{",
          //     )
          //     let mut ignore_offset = 0
          //     for i in 0..<rule_size {
          //       let type_name = sem.type_names[lr1.grammar.rules[sort][rule_i][i]]
          //       if Semantics::is_ignored(type_name) {
          //         ignore_offset += 1
          //       } else {
          //         self.builder.write_string(
          //           "\{field_names[i-ignore_offset]} : x\{i}, ",
          //         )
          //       }
          //     }
          //     self.builder.write_string("} |> Node::\{type_name}\n")
          //   }
          //   Reduction(parse_func_name~, ..) => {
          //     self.builder.write_string(
          //       "            let node = \{SEMANTIC_FUNC_PREFIX}\{parse_func_name}(",
          //     )
          //     for i in 0..<rule_size {
          //       let type_name = sem.type_names[lr1.grammar.rules[sort][rule_i][i]]
          //       if Semantics::is_NOT_ignored(type_name) {
          //         self.builder.write_string("x\{i}, ")
          //       }
          //     }
          //     self.builder.write_string(") |> Node::\{type_name}\n")
          //   }
          // }
          self.builder.write_string("            self.node_stack.push(node)\n")
        }
        _ => ()
      }

      // codegen goto
      let goto_map = lr1.goto_table[sort]
      match goto_map.length() {
        0 => // S' -> S
          self.builder.write_string("            break\n")
        1 => {
          let goto_code =
            $|            \{goto_map.values().peek().unwrap()}
            #|
          self.builder.write_string(goto_code)
        }
        _ => {
          let goto_header =
            #|            let former = self.state_stack[self.state_stack.length()-1]
            #|            match former {
            #|
          let goto_footer =
            #|              _ => break
            #|            }
            #|
          self.builder.write_string(goto_header)
          let alt_goto_map : Map[StateIndex, Array[StateIndex]] = Map::new()
          for state_jk in goto_map {
            let (state_j, state_k) = state_jk
            // state_j => state_k
            alt_goto_map.get_or_init(state_k, fn() { [] }).push(state_j)
          }
          for state_k_js in alt_goto_map {
            let (state_k, state_js) = state_k_js
            let state_js_code = state_js.map(Show::to_string).join(" | ")
            self.builder.write_string(
              "              \{state_js_code} => \{state_k}\n",
            )
          }
          self.builder.write_string(goto_footer)
        }
      }
      self.builder.write_string(reduce_footer)
    }
    self.builder.write_string("          _ => break\n")
    self.builder.write_string("        }\n")
    self.builder.write_string("    }\n")
  }
  self.builder.write_string(parse_footer)
}

///|
pub fn Generator::save(self : Self, path : String) -> Unit raise {
  self.lex_gen.save(path)
  let path = @path.Path::new(path)
  path.push("parser.mbt")
  @fs.write_string_to_file("\{path}", self.builder.to_string())
  path.pop() |> ignore
  path.push("syntax.mbt")
  @fs.write_string_to_file("\{path}", self.syntax_builder.to_string())
  path.pop() |> ignore
  path.push("interpreter.mbt")
  if false == path.is_exists() {
    @fs.write_string_to_file("\{path}", self.interpreter_builder.to_string())
  }
}
