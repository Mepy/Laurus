///|
struct Generator {
  builder : StringBuilder
  names : Array[String]
  nfas : Array[NFA]
  mut dfa_count : Int
  dfas : Map[TokenSet, Index] // using token_set to index dfa
} derive(Show)

///|
pub fn Generator::new(named_regexps : Array[(String, RegExp)]) -> Self {
  let builder = StringBuilder::new()
  let len = named_regexps.length()
  let names = Array::new(capacity=len + 1)
  let nfas = Array::new(capacity=len + 1)
  names.push(LAURUS_RESERVED_TOKEN_NAME)
  nfas.push(NFA::new([])) // ignore
  for i in 0..<len {
    let (name, regexp) = named_regexps[i]
    let name = name.to_upper()
    let nfa = regexp.to_token_nfa(i + 1)
    names.push(name)
    nfas.push(nfa)
  }
  let generator = { builder, names, nfas, dfa_count: 0, dfas: Map::new() }
  generator.init()
  generator
}

///|
fn Generator::init(self : Self) -> Unit {
  let token_type_header =
    #|///|
    #|pub enum TOKEN {
    #|
  let token_type_footer =
    #|} derive(Show)
    #|
  self.builder.write_string(token_type_header)
  for name in self.names {
    let token_type_constructor =
      $|  \{name}
      #|
    self.builder.write_string(token_type_constructor)
  }
  self.builder.write_string(token_type_footer)
  let lexer =
    #|///|
    #|pub struct Lexeme {
    #|  mut token : TOKEN
    #|  beg : Int
    #|  mut end : Int
    #|} derive(Show)
    #|
    #|///|
    #|fn Lexeme::new(beg? : Int = 0) -> Self {
    $|  { token: \{LAURUS_RESERVED_TOKEN_NAME}, beg, end: 0 }
    #|}
    #|
    #|///|
    #|struct Lexer {
    #|  mut src : String
    #|  mut cur : Int
    #|  mut lexeme : Lexeme
    #|} derive(Show)
    #|
    #|///|
    #|pub fn Lexer::new(src? : String = "") -> Self {
    #|  { src, cur: -1, lexeme: Lexeme::new() }
    #|}
    #|
    #|///|
    #|pub fn Lexer::init(self : Self, src : String, cur? : Int = -1) -> Unit {
    #|  self.src = src
    #|  self.cur = cur
    #|}
    #|
    #|///|
    #|pub fn Lexer::get(self : Self, lexeme : Lexeme) -> String {
    #|  let beg = lexeme.beg
    #|  let end = lexeme.end
    #|  self.src.unsafe_substring(start=beg, end=end + 1)
    #|}
    #|
    #|///|
    #|fn Lexer::next(self : Self) -> Int {
    #|  self.cur += 1 
    #|  if self.cur < self.src.length() {
    #|    self.src[self.cur]
    #|  } else {
    #|    -1
    #|  }
    #|}
    #|
    #|
  self.builder.write_string(lexer)
}

///|
pub fn Generator::add_dfa(self : Self, tokens : Set[Token]) -> Index {
  let tokens = TokenSet(tokens)
  match self.dfas.get(tokens) {
    Some(index) => index
    None => {
      let index = self.dfa_count
      self.unsafe_add_dfa(tokens.0.iter())
      self.dfas[tokens] = index
      index
    }
  }
}

///|
/// it does not check the redundancy, please do not use this directly.
/// use Generator::add_dfa instead
fn Generator::unsafe_add_dfa(self : Self, regexp_tokens : Iter[Index]) -> Unit {
  let nfa = regexp_tokens.map(token => self.nfas[token]) |> NFA::token_union
  let maker = DFAMaker::from_nfa(nfa)
  let dfa = maker.to_dfa()
  let scan_header =
    #|///|
    $|pub fn Lexer::scan\{self.dfa_count}(self : Self) -> Lexeme {
    #|  loop 0 {
    #|
  let scan_footer =
    #|    _ => break
    #|  }
    #|  let lexeme = self.lexeme
    #|  self.lexeme = Lexeme::new(beg=lexeme.end+1)
    #|  lexeme
    #|}
  self.builder.write_string(scan_header)
  let len = dfa.states.length()
  for i in 0..<len {
    let state = dfa.states[i]
    self.builder.write_string("    \{i} => {\n")
    match state.token {
      Some(token) => {
        self.builder.write_string("      self.lexeme.end = self.cur\n")
        self.builder.write_string(
          "      self.lexeme.token = \{self.names[token]}\n",
        )
      }
      None => ()
    }
    let maplen = state.next.length()
    if maplen == 0 {
      self.builder.write_string("      break\n")
    } else {
      self.builder.write_string("      continue match self.next() {\n")
      for k in 0..<maplen {
        let l = state.left[k]
        let r = state.right[k]
        let next = state.next[k]
        fn convert(l) {
          match l {
            '\u{0}' => "'\\u{0}'"
            '\u{10FFFF}' => "'\\u{10FFFF}'"
            '\'' => "'\\''"
            '\\' => "'\\\\'"
            _ as c => "'\{c}'"
          }
        }

        if l == r {
          self.builder.write_string("          \{convert(l)} => \{next}\n")
        } else {
          self.builder.write_string(
            "          \{convert(l)}..=\{convert(r)} => \{next}\n",
          )
        }
      }
      self.builder.write_string("          _ => break\n")
      self.builder.write_string("        }\n")
    }
    self.builder.write_string("    }\n")
  }
  self.builder.write_string(scan_footer)
  self.dfa_count += 1
}

///|
pub fn Generator::save(self : Self, path : String) -> Unit raise {
  let path = @path.Path::new(path)
  path.push("lexer.mbt")
  @fs.write_string_to_file("\{path}", self.builder.to_string())
}
