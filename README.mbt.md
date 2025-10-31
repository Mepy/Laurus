# Mepy/Laurus

**Laurus​**​ is a lexer and LR(1) parser generator written in MoonBit.


## How to use?
See the demo repo [arith.laurus](https://github.com/Mepy/arith.laurus/).
It contains a [file](https://github.com/Mepy/arith.laurus/blob/main/src/arith.laurus) for an example of **Laurus**' grammar.



## Features
Please refer to [examples](./src/tests/arith/).
- **Implicit priorities** of grammar rules for LR(1) conflicts resolution
- **Syntax types** auto generation
- **Unicode** supported, see the example [unicode](./src/tests/unicode/).


## Status

NOTICE: **​​Laurus​​** is still under active development. 
We do not (but will soon) provide a human-readable report when the parser or generator meets errors.
Please refer to `./src/**/test.mbt` if you are interested in the project.

```sh
$ tree src
src
├── dfa // reg_exp, nfa, dfa and codegen of lexer
├── lr1 // lr1 and codegen of parser
└── laurus // Laurus (concrete and abstract) syntax and its bootstrapping
```