open Printf
open Ast
open Parser

let get_token_list lexbuf =
  let rec work acc =
    match Lexer.token lexbuf with
    | EOF -> acc
    | t -> work (t::acc)
  in List.rev (work [])

let pp_token = function
    | NUM f -> "NUM(" ^ Float.to_string f ^ ")"
    | IDENT s -> s
    | PLUS -> "+"
    | MINUS -> "-"
    | TIMES -> "*"
    | DIVIDE -> "/"
    | CAT -> "@"
    | EQUAL -> "="
    | LPAREN -> "("
    | RPAREN -> ")"
    | LET -> "LET"
    | SEMI -> "SEMICOLON"
    | LBRACE -> "{"
    | RBRACE -> "}"
    | IF -> "IF"
    | FUN -> "FUN"
    | COMMA -> "COMMA"
    | EOF -> "EOF"
    | NEQ -> "!="
    | EQ -> "=="
    | LEQ -> "<="
    | GEQ -> ">="
    | LESS -> "<"
    | GREAT -> ">"
    | PRIM s -> "PRIM(" ^ s ^ ")"
;;

    (*
let main =
  let lexbuf = Lexing.from_channel stdin in
  (*let token_list = get_token_list lexbuf in
  List.map pp_token token_list |> List.iter (printf "%s\n");*)
  let res =
    try Parser.main Lexer.token lexbuf
    with
    | Lexer.Error c ->
       fprintf stderr "Lexical error at line %d: Unknown character '%c'\n"
         lexbuf.lex_curr_p.pos_lnum c;
       exit 1
    | Parser.Error ->
       fprintf stderr "Parse error at line %d:\n" lexbuf.lex_curr_p.pos_lnum;
       exit 1
*)
let main =
  let lexbuf = Lexing.from_channel (open_in Sys.argv.(1)) in
  let res =
    try Parser.main Lexer.token lexbuf
    with
    | Lexer.Error c ->
       fprintf stderr "Lexical error at line %d: Unknown character '%c'\n"
         lexbuf.lex_curr_p.pos_lnum c;
       exit 1
    | Parser.Error ->
       fprintf stderr "Parse error at line %d:\n" lexbuf.lex_curr_p.pos_lnum;
       exit 1
  in
    (*Ast.pprint_expr res |> print_endline;*)
    Interpreter.eval_expr res (fun x -> raise (Invalid_argument (x ^ " does not exist on stack")));
