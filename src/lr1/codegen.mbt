///|
struct Generator {
  builder : StringBuilder
  lex_gen : @dfa.Generator
} derive(Show)

///|
pub fn Generator::new(named_regexps : Array[(String, @dfa.RegExp)]) -> Self {
  let builder = StringBuilder::new()
  let lex_gen = @dfa.Generator::new(named_regexps)
  let generator = { builder, lex_gen }
  generator.init()
  generator
}

///|
fn Generator::init(self : Self) -> Unit {
  let parser =
    #|///|
    #|
    #|///|
    #|struct Parser {
    #|  lexer : Lexer
    #|  state_stack : Array[Int]
    #|} derive(Show)
    #|
    #|///|
    #|pub fn Parser::new(src? : String = "") -> Self {
    #|  { lexer: Lexer::new(src~), state_stack: Array::new() }
    #|}
    #|
    #|///|
    #|pub fn Parser::init(self : Self, src : String, cur? : Int = -1) -> Unit {
    #|  self.lexer.init(src, cur~)
    #|  self.state_stack.clear()
    #|}
    #|
  self.builder.write_string(parser)
}

///|
pub fn Generator::codegen(
  self : Self,
  lr1 : LR1,
  names : Array[String],
) -> Unit {
  // codegen dfas
  for dfa_token in lr1.dfa_tokens {
    self.lex_gen.codegen(dfa_token.iter())
  }
  // codegen scan
  let scan_header =
    #|///|
    #|pub fn Parser::scan(self : Self) -> Unit {
    #|  let mut lexeme = self.lexer.scan0()
    #|  loop 0 {
    #|
  let scan_footer =
    #|    _ => break
    #|  }
    #|
    #|}
    #|
  self.builder.write_string(scan_header)
  let state_len = lr1.states.length()
  for state_i in 0..<state_len {
    self.builder.write_string("    \{state_i} => { // state_\{state_i}\n")
    // codegen LR1 items
    for item in lr1.states[state_i] {
      self.builder.write_string("      // \{names[item.sort]} ->") // indent
      let sentence_len = item.sentence.length()
      for i in 0..<item.cur {
        self.builder.write_string(" \{names[item.sentence[i]]}")
      }
      self.builder.write_string(" ●")
      for i in item.cur..<sentence_len {
        self.builder.write_string(" \{names[item.sentence[i]]}")
      }
      self.builder.write_string(" | \{names[item.lookahead]}\n")
    }
    self.builder.write_string("      continue match lexeme.token {\n")
    let shift_map = lr1.shift_table[state_i]
    let reduce_map = lr1.reduce_table[state_i]
    for token_state_dfa in shift_map {
      let (token, (state_j, dfa_j)) = token_state_dfa
      let token_name = names[token].to_upper()
      let shift_code =
        $|          \{token_name} => { // shift
        $|            lexeme = self.lexer.scan\{dfa_j}()
        $|            \{state_j}
        #|          }
        #|
      self.builder.write_string(shift_code)
    }
    for token_sort_rule_i_size in reduce_map {
      let (token, (sort, _rule_i, rule_size)) = token_sort_rule_i_size
      let token_name = names[token].to_upper()
      let reduce_header =
        $|          \{token_name} => { // reduce
        $|
      let reduce_footer =
        #|          }
        #|
      self.builder.write_string(reduce_header)
      for i in 0..<rule_size {
        self.builder.write_string(
          "            self.state_stack.unsafe_pop() |> ignore\n",
        )
      }
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
  self.builder.write_string(scan_footer)
}

///|
pub fn Generator::save(self : Self, path : String) -> Unit raise {
  self.lex_gen.save(path)
  let path = @path.Path::new(path)
  path.push("parser.mbt")
  @fs.write_string_to_file("\{path}", self.builder.to_string())
}
