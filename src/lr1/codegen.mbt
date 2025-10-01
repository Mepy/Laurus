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
  maker : LR1Maker,
  names : Array[String],
) -> Unit {
  let _lexer_scan0 = self.lex_gen.add_dfa(
    maker.first_table[0].iter().map(token => token - maker.sort_len)
    |> Set::from_iter,
  )
  let state_len = maker.goto_table.length()
  let goto_table = Array::makei(maker.sort_len, _ => Map::new(
    capacity=state_len,
  ))
  for state_i in 0..<state_len {
    for sort_next in maker.goto_table[state_i] {
      let (sort, next) = sort_next
      goto_table[sort][state_i] = next
    }
  }
  let scan_header =
    #|///|
    #|pub fn Parser::scan(self : Self) -> Unit {
    #|  let mut lexeme = self.lexer.scan0()
    $|  let goto_table = \{goto_table}
    #|  loop 0 {
    #|
  let scan_footer =
    #|    _ => break
    #|  }
    #|
    #|}
    #|
  self.builder.write_string(scan_header)
  let state_len = maker.goto_table.length()
  for i in 0..<state_len {
    self.builder.write_string("    \{i} => {\n")
    self.builder.write_string("      continue match lexeme.token {\n")
    let shift_map = maker.shift_table[i]
    let reduce_map = maker.reduce_table[i]
    for token_state_xxxx in shift_map {
      let (token, (next_state, _)) = token_state_xxxx
      let token_name = names[token].to_upper()
      let next_dfa = self.lex_gen.add_dfa(
        maker.first_table[next_state]
        .iter()
        .map(token => token - maker.sort_len)
        |> Set::from_iter,
      )
      let shift_code =
        $|          \{token_name} => { // shift
        $|            lexeme = self.lexer.scan\{next_dfa}()
        $|            \{next_state}
        #|          }
        #|
      self.builder.write_string(shift_code)
    }
    for token_sort_rules in reduce_map {
      let (token, sort_rules) = token_sort_rules
      let (sort, rule_i) = sort_rules[0]
      let token_name = names[token].to_upper()
      let rule_size = maker.grammar.rules[sort][rule_i].length()
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
      let goto_table_sort = goto_table[sort]
      match goto_table_sort.size() {
        0 => // S' -> S
          self.builder.write_string("            break\n")
        1 => {
          let goto_code =
            $|            \{goto_table_sort.values().peek().unwrap()}
            #|
          self.builder.write_string(goto_code)
        }
        _ => {
          let goto_code =
            #|            let former_state = self.state_stack[self.state_stack.length()-1]
            $|            let next = goto_table[\{sort}][former_state]
            #|            next
            #|
          self.builder.write_string(goto_code)
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
