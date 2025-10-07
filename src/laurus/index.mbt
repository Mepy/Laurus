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
    guard parser.parse() is Some(laurus) else {  }
    let par_gen = laurus.par_gen()
    // println(laurus)
    path.pop() |> ignore
    // println(path.to_string())
    par_gen.save(path.to_string())
  } catch {
    _ => println("unknown error")
  }
}
