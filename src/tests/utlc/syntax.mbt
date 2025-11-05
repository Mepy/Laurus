///|
pub(all) enum Term {
  Var(String)
  Abs(String, Term)
  App(Term, Term)
} derive(Show)
