///|
fn Laurus::new() -> Laurus {
  {
    comments: Array::new(),
    space: Emp,
    start: "",
    token_names: Array::new(),
    token_convs: Array::new(),
    token_reg_exps: Array::new(),
    sort_names: Array::new(),
    sort_types: Array::new(),
    sort_rules: Array::new(),
  }
}

///|
fn Laurus::add_comment(self : Laurus, comment : String) -> Laurus {
  self.comments.push(comment)
  self
}

///|
fn Laurus::set_space(self : Laurus, reg_exp : RegExp) -> Laurus {
  self.space = reg_exp
  self
}

///|
fn Laurus::set_start(self : Laurus, sort_name : String) -> Laurus {
  self.start = sort_name
  self
}

///|
fn Laurus::add_token(
  self : Laurus,
  token_name : String,
  token_conv : TokenConv,
  token_reg_exp : RegExp,
) -> Laurus {
  self.token_names.push(token_name)
  self.token_convs.push(token_conv)
  self.token_reg_exps.push(token_reg_exp)
  self
}

///|
fn Laurus::add_sort(
  self : Laurus,
  sort_name : String,
  sort_type : SortType,
  rules : Array[Rule],
) -> Laurus {
  self.sort_names.push(sort_name)
  self.sort_types.push(sort_type)
  self.sort_rules.push(rules)
  self
}

///|
#inline
fn Char::esc_origin(str : String) -> Char {
  str[0].unsafe_to_char()
}

///|
#inline
fn Char::esc_space(str : String) -> Char {
  match str[0] {
    's' => ' '
    't' => '\t'
    'n' => '\n'
    _ => ' '
  }
}

///|
#inline
fn Char::esc_unicode(unicode : String) -> Char {
  let mut code = 0
  for c in unicode {
    let x = match c {
      '0' => 0
      '1' => 1
      '2' => 2
      '3' => 3
      '4' => 4
      '5' => 5
      '6' => 6
      '7' => 7
      '8' => 8
      '9' => 9
      'a' | 'A' => 10
      'b' | 'B' => 11
      'c' | 'C' => 12
      'd' | 'D' => 13
      'e' | 'E' => 14
      'f' | 'F' => 15
      _ => 0
    }
    code = code * 16 + x
  }
  code.unsafe_to_char()
}

///|
#inline
fn[T] Array::singleton(x : T) -> Array[T] {
  [x]
}

///|
#inline
fn[T] Array::empty() -> Array[T] {
  Array::new()
}

///|
#inline
fn[T] Array::snoc(array : Array[T], x : T) -> Array[T] {
  array.push(x)
  array
}

///|
#inline
fn Range::single(c : Char) -> Range {
  Range(c, c)
}
