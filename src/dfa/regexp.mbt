///|
enum RegExp {
  Single(CodePoint)
  Range(CodePoint, CodePoint)
  Bor(Array[(CodePoint, CodePoint)])
  Bnot(Array[(CodePoint, CodePoint)])
  Any
  Emp
  Union(Array[RegExp])
  Seq(Array[RegExp])
  Star(RegExp)
  Plus(RegExp)
  String(String)
} derive(Show)

///|
fn RegExp::check(self : RegExp) -> Unit raise {
  match self {
    RegExp::Single(c) =>
      assert_true(
        c >= MinCodePoint && c <= MaxCodePoint,
        msg="Single: codepoint \"\{c}\" out of range",
      )
    RegExp::Range(l, r) =>
      assert_true(
        l <= r && l >= MinCodePoint && r <= MaxCodePoint,
        msg="Range: invalid range [\{l}, \{r}]",
      )
    RegExp::Bor(arr) => {
      assert_true(arr.length() > 0, msg="Bor: empty ranges")
      for lr in arr {
        let (l, r) = lr
        assert_true(
          l <= r && l >= MinCodePoint && r <= MaxCodePoint,
          msg="Bor: invalid range [\{l}, \{r}]",
        )
      }
    }
    RegExp::Bnot(arr) => {
      assert_true(arr.length() > 0, msg="Bnot: empty ranges")
      for lr in arr {
        let (l, r) = lr
        assert_true(
          l <= r && l >= MinCodePoint && r <= MaxCodePoint,
          msg="Bnot: invalid range [\{l}, \{r}]",
        )
      }
    }
    RegExp::Any => ()
    RegExp::Emp => ()
    RegExp::Union(arr) =>
      for re in arr {
        re.check()
      }
    RegExp::Seq(arr) =>
      for re in arr {
        re.check()
      }
    RegExp::Star(re) => re.check()
    RegExp::Plus(re) => re.check()
    RegExp::String(_) => ()
  }
}

///|
fn RegExp::to_nfa(self : RegExp) -> NFA {
  match self {
    RegExp::Single(c) => NFA::single(c)
    RegExp::Range(l, r) => NFA::range(l, r)
    RegExp::Bor(arr) => NFA::bor(arr)
    RegExp::Bnot(arr) => NFA::bnot(arr)
    RegExp::Any => NFA::any()
    RegExp::Emp => NFA::emp()
    RegExp::Union(arr) => {
      let nfas = Array::new(capacity=arr.length())
      for re in arr {
        nfas.push(re.to_nfa())
      }
      NFA::union(nfas)
    }
    RegExp::Seq(arr) => {
      let nfas = Array::new(capacity=arr.length())
      for re in arr {
        nfas.push(re.to_nfa())
      }
      NFA::seq(nfas)
    }
    RegExp::Star(re) => re.to_nfa().star()
    RegExp::Plus(re) => re.to_nfa().plus()
    RegExp::String(s) => NFA::string(s)
  }
}

///|
fn RegExp::to_nfa_rev(self : RegExp) -> NFA {
  match self {
    RegExp::Single(c) => NFA::single(c)
    RegExp::Range(l, r) => NFA::range(l, r)
    RegExp::Bor(arr) => NFA::bor(arr)
    RegExp::Bnot(arr) => NFA::bnot(arr)
    RegExp::Any => NFA::any()
    RegExp::Emp => NFA::emp()
    RegExp::Union(arr) => {
      let nfas = Array::new(capacity=arr.length())
      for re in arr {
        nfas.push(re.to_nfa_rev())
      }
      NFA::union(nfas)
    }
    RegExp::Seq(arr) => {
      let nfas = Array::new(capacity=arr.length())
      for re in arr {
        nfas.push(re.to_nfa_rev())
      }
      NFA::seq_rev(nfas)
    }
    RegExp::Star(re) => re.to_nfa_rev().star()
    RegExp::Plus(re) => re.to_nfa_rev().plus()
    RegExp::String(s) => NFA::string_rev(s)
  }
}

///|
fn RegExp::to_token_nfa(self : RegExp, token : Token) -> NFA {
  let nfa_rev = self.to_nfa_rev()
  let maker = DFAMaker::from_nfa(nfa_rev)
  let dfa_rev = maker.to_dfa()
  let nfa = dfa_rev.to_nfa_rev(token~)
  nfa
}

///|
/// Brzozowski 算法，从一组正则表达式和对应的 token 构造最小 DFA
fn brzozowski(regexp_tokens : Array[(RegExp, Token)]) -> DFA raise {
  for regexp_token in regexp_tokens {
    let (regexp, _) = regexp_token
    regexp.check()
  }
  let nfas = regexp_tokens
    .iter()
    .map(regexp_token => {
      let (regexp, token) = regexp_token
      let nfa_rev = regexp.to_nfa_rev()
      let maker = DFAMaker::from_nfa(nfa_rev)
      let dfa_rev = maker.to_dfa()
      let nfa = dfa_rev.to_nfa_rev(token~)
      nfa
    })
  let nfa = NFA::token_union(nfas)
  let maker = DFAMaker::from_nfa(nfa)
  let dfa = maker.to_dfa()
  if maker.conflicts.is_empty() == false {
    raise TokenConflicts(maker.conflicts)
  }
  return dfa
}
