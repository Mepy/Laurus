///|
fn main {
  let args = @sys.get_cli_args()
  guard args.length() == 2 else {
    println("please provide only the path of grammar.laurus file.")
    println("$ laurus <path/to/grammar.laurus>")
  }
  let path = args[1]
  @laurus.generate(path)
}
