///|
enum Expr {
	Add(Expr, Expr, )
	Sub(Expr, Expr, )
	Mul(Expr, Expr, )
	Div(Expr, Expr, )
	Pow(Expr, Expr, )
	Lit(Int, )
} derive(Show)
