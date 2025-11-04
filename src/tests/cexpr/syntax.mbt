///|
pub(all) enum Expr {
  Assign(String, Expr)
  Triple(Expr, Expr, Expr)
  Lit(Int)
  Var(String)
} derive(Show)
