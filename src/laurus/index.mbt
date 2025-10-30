///|
pub fn generate(path : String) -> Unit {
  let parser = Parser::new()
  let path = @path.Path::new(path)
  guard path.is_exists() else {
    println("please provide a valid path of grammar.laurus file.")
  }
  guard path.is_file() else {
    println(
      "please provide a valid path of grammar.laurus file, not a directory.",
    )
  }
  try {
    let source = @fs.read_file_to_string(path.to_string())
    parser.init(source)
    let laurus = parser.parse()
    let par_gen = laurus.par_gen()
    // println(laurus)
    path.pop() |> ignore
    // println(path.to_string())
    par_gen.save(path.to_string())
  } catch {
    @fs.IOError(io_err) => println("IO Error : \{io_err}")
    ExpectTokens(beg, end, tokens) => {
      let error_msg =
        $|LaurusParseError of file \{path}
        $|at \{beg}-\{end}, expect tokens : \{tokens}
      println(error_msg)
    }
    e => println("unknown error : \{e}")
  }
}
