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
    #|struct Parser {
    #|  lexer : Lexer
    #|  state_stack : Array[Int]
    #|  node_stack : Array[Node]
    #|} derive(Show)
    #|
    #|///|
    #|pub fn Parser::new(src? : String = "") -> Self {
    #|  {
    #|    lexer: Lexer::new(src~),
    #|    state_stack: Array::new(),
    #|    node_stack: Array::new(),
    #|  }
    #|}
    #|
    #|///|
    #|pub fn Parser::init(self : Self, src : String, cur? : Int = -1) -> Unit {
    #|  self.lexer.init(src, cur~)
    #|  self.state_stack.clear()
    #|  self.node_stack.clear()
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
pub fn Generator::codegen_sort_type(
  self : Self,
  lr1 : LR1,
  sem : Semantics,
) -> Unit {
  let sort_len = sem.sorts.length()
  for sort_i in 0..<sort_len {
    let sort = sem.sorts[sort_i]
    let rules = sem.rules[sort_i]
    match sort.tag {
      EnumType => {
        let sort_header =
          #|///|
          $|enum \{sort.type_name} {
          #|
        let sort_footer =
          #|} derive(Show)
          #|
        self.syntax_builder.write_string(sort_header)
        let rule_len = rules.length()
        for rule_i in 0..<rule_len {
          let rule = rules[rule_i]
          match rule {
            Constructor(name) => {
              self.syntax_builder.write_string("  \{name}(")
              for symbol in lr1.grammar.rules[sort_i][rule_i] {
                let type_name = sem.type_names[symbol]
                if Semantics::is_NOT_ignored(type_name) {
                  self.syntax_builder.write_string("\{type_name}, ")
                }
              }
              self.syntax_builder.write_string(")\n")
            }
            NamedConstructor(name, field_names~) => {
              self.syntax_builder.write_string(" \{name}(")
              let sentence = lr1.grammar.rules[sort_i][rule_i]
              let rule_size = sentence.length()
              let mut ignore_offset = 0
              for i in 0..<rule_size {
                let type_name = sem.type_names[sentence[i]]
                if Semantics::is_ignored(type_name) {
                  ignore_offset += 1
                } else {
                  self.syntax_builder.write_string(
                    "\{field_names[i - ignore_offset]}~ : \{type_name}, ",
                  )
                }
              }
              self.syntax_builder.write_string(")\n")
            }
            _ => ()
          }
        }
        self.syntax_builder.write_string(sort_footer)
      }
      StructType => {
        let sort_header =
          #|///|
          $|struct \{sort.type_name} {
          #|
        let sort_footer =
          #|} derive(Show)
          #|
        self.syntax_builder.write_string(sort_header)
        let rule_len = rules.length()
        for rule_i in 0..<rule_len {
          let rule = rules[rule_i]
          match rule {
            Fields(field_names) => {
              let sentence = lr1.grammar.rules[sort_i][rule_i]
              let rule_size = sentence.length()
              let mut ignore_offset = 0
              for i in 0..<rule_size {
                let type_name = sem.type_names[sentence[i]]
                if Semantics::is_ignored(type_name) {
                  ignore_offset += 1
                } else {
                  self.syntax_builder.write_string(
                    "  \{field_names[i - ignore_offset]} : \{type_name}\n",
                  )
                }
              }
            }
            _ => ()
          }
        }
        self.syntax_builder.write_string(sort_footer)
      }
      TupleType => {
        let sort_header =
          #|///|
          $|struct \{sort.type_name} (
        let sort_footer =
          #|) derive(Show)
          #|
        self.syntax_builder.write_string(sort_header)
        let rule_len = rules.length()
        for rule_i in 0..<rule_len {
          let rule = rules[rule_i]
          match rule {
            Tuple =>
              for symbol in lr1.grammar.rules[sort_i][rule_i] {
                let type_name = sem.type_names[symbol]
                if Semantics::is_NOT_ignored(type_name) {
                  self.syntax_builder.write_string("\{type_name}, ")
                }
              }
            _ => ()
          }
        }
        self.syntax_builder.write_string(sort_footer)
      }
      AsType => ()
    }
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
  for type_name in Set::from_array(sem.type_names) {
    if Semantics::is_NOT_ignored(type_name) {
      self.builder.write_string("  \{type_name}(\{type_name})\n")
    }
  }
  self.builder.write_string(node_footer)
}

///|
pub fn Generator::codegen_interpreter(
  self : Self,
  lr1 : LR1,
  sem : Semantics,
) -> Unit {
  let interpreter_header =
    #|///|
    #|struct Interpreter {} derive(Show)
    #|
  self.interpreter_builder.write_string(interpreter_header)
  for token in sem.tokens {
    guard token is Conversion(type_name~, parse_func_name~, ..) else {
      continue
    }
    if Semantics::is_identity_func_name(parse_func_name) &&
      Semantics::is_identity(type_name) {
      continue
    }
    let func_code =
      #|///|
      #|#inline
      $|fn \{SEMANTIC_FUNC_PREFIX}\{parse_func_name}(str : String) -> \{type_name} {
      #|  ...
      #|}
      #|
    self.interpreter_builder.write_string(func_code)
  }
  let sort_len = sem.sorts.length()
  for sort in 0..<sort_len {
    let rules = sem.rules[sort]
    let rule_len = rules.length()
    for rule_i in 0..<rule_len {
      guard rules[rule_i]
        is Reduction(parse_func_name~, parse_parameter_names~, ..) else {
        continue
      }
      let func_header =
        #|///|
        #|#inline
        $|fn \{SEMANTIC_FUNC_PREFIX}\{parse_func_name}(
      let func_footer =
        #|  ...
        #|}
        #|
      self.interpreter_builder.write_string(func_header)
      let sentence = lr1.grammar.rules[sort][rule_i]
      let rule_size = sentence.length()
      let mut ignore_offset = 0
      for i in 0..<rule_size {
        let type_name = sem.type_names[lr1.grammar.rules[sort][rule_i][i]]
        if Semantics::is_ignored(type_name) {
          ignore_offset += 1
        } else {
          self.interpreter_builder.write_string(
            "\{parse_parameter_names[i - ignore_offset]} : \{type_name}, ",
          )
        }
      }
      self.interpreter_builder.write_string(") -> \{sem.type_names[sort]}{\n")
      self.interpreter_builder.write_string(func_footer)
    }
  }
}

///|
pub fn Generator::codegen_lexer(self : Self, lr1 : LR1) -> Unit {
  // codegen dfas
  for dfa_token in lr1.dfa_tokens {
    self.lex_gen.codegen(dfa_token)
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
    $|pub fn Parser::parse(self : Self) -> \{sem.type_names[1]}? {
    #|  let mut lexeme = self.lexer.scan0()
    #|  loop 0 {
    #|
  let parse_footer =
    #|    _ => break
    #|  }
    #|  match self.node_stack[0] {
    $|    \{sem.type_names[1]}(node) => Some(node)
    $|    _ => None
    #|  }
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

    // codegen shift
    for token_state_dfa in shift_map {
      let (token, (state_j, dfa_j)) = token_state_dfa
      let token_name = sem.names[token].to_upper()
      let shift_header =
        $|          \{token_name} => { // shift
        #|
      let shift_footer =
        $|            lexeme = self.lexer.scan\{dfa_j}()
        $|            \{state_j}
        #|          }
        #|
      self.builder.write_string(shift_header)
      // token - lr1.sort_len !!!
      match sem.tokens[token - lr1.sort_len] {
        Ignore =>
          self.builder.write_string("            // ignore the old lexeme\n")
        BuiltIn("Lexeme") =>
          self.builder.write_string(
            "            self.node_stack.push(Node::Lexeme(lexeme))\n",
          )
        BuiltIn("String") => {
          let shift_node =
            $|            let node = self.lexer.get(lexeme) |> Node::String
            $|            self.node_stack.push(node)
            $|
          self.builder.write_string(shift_node)
        }
        BuiltIn(unknown) =>
          // We will not finish this branch until there are more builtins
          ...
        Conversion(type_name~, parse_func_name~, ..) =>
          if Semantics::is_identity_func_name(parse_func_name) &&
            Semantics::is_identity(type_name) {
            let shift_node =
              $|            let node = self.lexer.get(lexeme) |> Node::\{type_name}
              $|            self.node_stack.push(node)
              $|
            self.builder.write_string(shift_node)
          } else {
            let shift_node =
              $|            let node = self.lexer.get(lexeme) |> \{SEMANTIC_FUNC_PREFIX}\{parse_func_name} |> Node::\{type_name}
              $|            self.node_stack.push(node)
              $|
            self.builder.write_string(shift_node)
          }
      }
      self.builder.write_string(shift_footer)
    }

    // codegen reduce
    for token_sort_rule_i_size in reduce_map {
      let (token, (sort, rule_i, rule_size)) = token_sort_rule_i_size
      let token_name = sem.names[token].to_upper()
      let reduce_header =
        $|          \{token_name} => { // reduce
        $|
      let reduce_footer =
        #|          }
        #|
      self.builder.write_string(reduce_header)
      // pop state_stack
      for i in 0..<rule_size {
        self.builder.write_string(
          "            self.state_stack.unsafe_pop() |> ignore\n",
        )
      }

      // pop node_stack
      for i = rule_size - 1; i >= 0; i = i - 1 {
        let type_name = sem.type_names[lr1.grammar.rules[sort][rule_i][i]]
        if Semantics::is_ignored(type_name) {
          self.builder.write_string(
            "            //                             ignore Node::\{INGORED_TYPE_NAME}(x\{i})\n",
          )
        } else {
          self.builder.write_string(
            "            guard self.node_stack.unsafe_pop() is Node::\{type_name}(x\{i})\n",
          )
        }
      }
      // construct new node according to the semantics of the rule
      let type_name = sem.type_names[sort]
      if Semantics::is_NOT_ignored(type_name) {
        match sem.rules[sort][rule_i] {
          Constructor(constructor_name) => {
            self.builder.write_string(
              "            let node = \{constructor_name}(",
            )
            for i in 0..<rule_size {
              let type_name = sem.type_names[lr1.grammar.rules[sort][rule_i][i]]
              if Semantics::is_NOT_ignored(type_name) {
                self.builder.write_string("x\{i}, ")
              }
            }
            self.builder.write_string(") |> Node::\{type_name}\n")
          }
          NamedConstructor(constructor_name, field_names~) => {
            self.builder.write_string(
              "            let node = \{constructor_name}(",
            )
            let mut ignore_offset = 0
            for i in 0..<rule_size {
              let type_name = sem.type_names[lr1.grammar.rules[sort][rule_i][i]]
              if Semantics::is_ignored(type_name) {
                ignore_offset += 1
              } else {
                self.builder.write_string(
                  "\{field_names[i - ignore_offset]} = x\{i}, ",
                )
              }
            }
            self.builder.write_string(") |> Node::\{type_name}\n")
          }
          Tuple => {
            self.builder.write_string("            let node = \{type_name}(")
            for i in 0..<rule_size {
              let type_name = sem.type_names[lr1.grammar.rules[sort][rule_i][i]]
              if Semantics::is_NOT_ignored(type_name) {
                self.builder.write_string("x\{i}, ")
              }
            }
            self.builder.write_string(") |> Node::\{type_name}\n")
          }
          Fields(field_names) => {
            self.builder.write_string("            let node = \{type_name}::{")
            let mut ignore_offset = 0
            for i in 0..<rule_size {
              let type_name = sem.type_names[lr1.grammar.rules[sort][rule_i][i]]
              if Semantics::is_ignored(type_name) {
                ignore_offset += 1
              } else {
                self.builder.write_string(
                  "\{field_names[i-ignore_offset]} : x\{i}, ",
                )
              }
            }
            self.builder.write_string("} |> Node::\{type_name}\n")
          }
          Reduction(parse_func_name~, ..) => {
            self.builder.write_string(
              "            let node = \{SEMANTIC_FUNC_PREFIX}\{parse_func_name}(",
            )
            for i in 0..<rule_size {
              let type_name = sem.type_names[lr1.grammar.rules[sort][rule_i][i]]
              if Semantics::is_NOT_ignored(type_name) {
                self.builder.write_string("x\{i}, ")
              }
            }
            self.builder.write_string(") |> Node::\{type_name}\n")
          }
        }
        self.builder.write_string("            self.node_stack.push(node)\n")
      }

      // codegen goto
      let goto_map = lr1.goto_table[sort]
      match goto_map.size() {
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
          for state_jk in goto_map {
            let (state_j, state_k) = state_jk
            self.builder.write_string(
              "              \{state_j} => \{state_k}\n",
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
