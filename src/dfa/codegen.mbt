///|
struct Generator {
  builder : StringBuilder
  names : Array[String]
  nfas : Array[NFA]
  mut dfa_count : Int
} derive(Show)

///|
pub fn Generator::new(names : Array[String], nfas : Array[NFA]) -> Self {
  let builder = StringBuilder::new()
  let generator = { builder, names, nfas, dfa_count: 0 }
  generator.init()
  generator.codegen_skip_space()
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
    #|pub struct Location {
    #|  mut row : Int
    #|  mut col : Int
    #|  mut off : Int
    #|} derive(Show)
    #|
    #|///|
    #|impl Default for Location with default(){
    #|  Location::{row:0, col:0, off:0}
    #|}
    #|
    #|///|
    #|fn Location::clone(self : Self) -> Self {
    #|  let {row, col, off} = self
    #|  {row, col, off}
    #|}
    #|
    #|///|
    #|pub struct Lexeme {
    #|  mut token : TOKEN
    #|  mut beg : Location
    #|  mut end : Location
    #|} derive(Show)
    #|
    #|///|
    #|fn Lexeme::new(beg? : Location = Location::default()) -> Self {
    $|  { token: \{self.names[0]}, beg, end: Location::default() }
    #|}
    #|
    #|///|
    #|fn Lexeme::init(self : Self) -> Unit {
    $|  self.token = \{self.names[0]}
    #|  self.beg = Location::default()
    #|}
    #|
    #|
    #|///|
    #|struct Lexer {
    #|  mut src : String
    #|  mut cur : Location
    #|  mut lexeme : Lexeme
    #|} derive(Show)
    #|
    #|///|
    #|pub fn Lexer::new(src? : String = "") -> Self {
    #|  { src, cur: Location::default(), lexeme: Lexeme::new() }
    #|}
    #|
    #|///|
    #|pub fn Lexer::init(self : Self, src : String, cur? : Location = Location::default()) -> Unit {
    #|  self.src = src
    #|  self.cur = cur
    #|  self.lexeme.init()
    #|}
    #|
    #|///|
    #|pub fn Lexer::cur_loc(self : Self) -> Location {
    #|	self.cur.clone()
    #|}
    #|
    #|///|
    #|pub fn Lexer::get(self : Self, lexeme : Lexeme) -> String {
    #|  let beg = lexeme.beg
    #|  let end = lexeme.end
    #|  self.src.unsafe_substring(start=beg.off, end=end.off)
    #|}
    #|
    #|///|
    #|fn Lexer::next(self : Self) -> Int {
    #|  let cur_off = self.cur.off
    #|  guard cur_off < self.src.length() else { -1 }
    #|  match self.src[cur_off] {
    #|    0xD800..=0xDBFF as lead => {
    #|      let tail = self.src[cur_off + 1]
    #|      self.cur.off += 2
    #|      self.cur.col += 1
    #|      (((lead & 0x3FF) << 10) | (tail & 0x3FF)) + 0x10000
    #|    }
    #|    0xA as c => {
    #|      self.cur.off += 1
    #|      self.cur.row += 1
    #|      self.cur.col = 0
    #|      c
    #|    }
    #|    _ as c => {
    #|      self.cur.off += 1
    #|      self.cur.col += 1
    #|      c
    #|    }
    #|  }
    #|}
    #|
    #|
  self.builder.write_string(lexer)
}

///|
fn Generator::codegen_dfa(self : Self, dfa : DFA, scan_header : String) -> Unit {
  let scan_footer =
    #|    _ => break
    #|  }
    #|  let lexeme = self.lexeme
    #|  self.cur = lexeme.end.clone()
    #|  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
    #|  lexeme
    #|}
    #|
  self.builder.write_string(scan_header)
  let len = dfa.states.length()
  for i in 0..<len {
    let state = dfa.states[i]
    self.builder.write_string("    \{i} => {\n")
    match state.token {
      Some(token) => {
        self.builder.write_string("      self.lexeme.end = self.cur.clone()\n")
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
            ' ' => "' '"
            '\t' => "'\\t'"
            '\n' => "'\\n'"
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
}

///|
pub fn Generator::codegen_scan(
  self : Self,
  regexp_tokens : Array[Index],
) -> Unit {
  let nfa = regexp_tokens.iter().map(token => self.nfas[token])
    |> NFA::token_union
  let maker = DFAMaker::from_nfa(nfa)
  let dfa = maker.to_dfa()
  let token_names = {
    regexp_tokens.sort()
    regexp_tokens.map(token => self.names[token]).join(", "[:])
  }
  let scan_header =
    #|///|
    $|pub fn Lexer::scan\{self.dfa_count}(self : Self) -> Lexeme {
    $|  // [\{token_names}]
    $|  self.skip_space() |> ignore
    #|  loop 0 {
    #|
  self.codegen_dfa(dfa, scan_header)
  self.dfa_count += 1
}

///|
/// We assume nfas[1] is the space, and names[1] = LAURUS_RESERVED_SPACE
pub fn Generator::codegen_skip_space(self : Self) -> Unit {
  let nfa = self.nfas[1]
  let maker = DFAMaker::from_nfa(nfa)
  let dfa = maker.to_dfa()
  let scan_header =
    #|///|
    $|pub fn Lexer::skip_space(self : Self) -> Lexeme {
    #|  loop 0 {
    #|
  self.codegen_dfa(dfa, scan_header)
}

///|
pub fn Generator::save(self : Self, path : String) -> Unit raise {
  let path = @path.Path::new(path)
  path.push("lexer.mbt")
  @fs.write_string_to_file("\{path}", self.builder.to_string())
}
