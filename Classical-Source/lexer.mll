{
  open Parser
  exception Error of char
}

let letter = ['A'-'Z'] | ['a'-'z']
let digit = ['0'-'9']
let non_digit = '_' | letter
let ident = letter (digit | non_digit)*
let pident = "_prim_" (digit | non_digit)*
let opchar = '+' | '-' | '*' | '/' | '@' | '<' | '>' | '=' | '!'
let op = (opchar)*

let line_comment = "//" [^ '\n']*

rule token = parse
    |  [' ' '\t' '\n'] | line_comment
        { token lexbuf }
    | [';']
        { SEMI }
    | ident as str
        { match str with
          | "let" -> LET
          | "fun" -> FUN
          | "if" -> IF
          | s -> IDENT(s)
        }
    | pident as str
        { PRIM(str) }
    | op as str
        { match str with
            | "+" -> PLUS
            | "-" -> MINUS
            | "*" -> TIMES
            | "/" -> DIVIDE
            | "@" -> CAT
            | "<" -> LESS
            | ">" -> GREAT
            | "<=" -> LEQ
            | ">=" -> GEQ
            | "==" -> EQ
            | "!=" -> NEQ
            | "=" -> EQUAL
        }
    | digit+ as lxm
        { NUM(Float.of_string lxm) }
    | [',']
        { COMMA }
    | ['(']
        { LPAREN }
    | [')']
        { RPAREN }
    | ['{']
        { LBRACE }
    | ['}']
        { RBRACE }
    | eof
        { EOF }
    | _ as c
        { raise (Error c) }

