%{
    open Ast
%}

%token <float> NUM
%token <string> IDENT
%token <string> PRIM
%token CAT "@"
%token PLUS "+"
%token MINUS "-"
%token TIMES "*"
%token DIVIDE "/"
%token EQUAL "="
%token LEQ "<="
%token LESS "<"
%token GEQ ">="
%token GREAT ">"
%token EQ "=="
%token NEQ "!="
%token LPAREN "("
%token RPAREN ")"
%token LBRACE "{"
%token RBRACE "}"
%token IF
%token FUN
%token LET
%token SEMI ";"
%token COMMA ","
%token EOF

%left LEQ LESS GEQ GREAT EQ NEQ
%left CAT
%left PLUS MINUS
%left TIMES DIVIDE

%start main
%type <expr> main
%%

main:
    | e = expr
    {e}

expr:
    | EOF
        { ENone }
    | LET id = IDENT EQUAL v = value SEMI e = expr
        { ELet((id,[]), v, e) }
    | FUN id = IDENT LPAREN p = plist RPAREN LBRACE code = expr RBRACE e = expr
        { EFun(id, p, code, e) }
    | IF LPAREN v = value RPAREN LBRACE et = expr RBRACE LBRACE ef = expr RBRACE e = expr
        { EIf(v, et, ef, e) }
    | v = funcall SEMI e = expr
        { EApp(fst v, snd v, e) }
    | p = PRIM v = value e = expr
        { EPrim(p, v, e) }
    | LET id = IDENT EQUAL v = value SEMI
        { ELet((id,[]), v, ENone) }
    | FUN id = IDENT LPAREN p = plist RPAREN LBRACE code = expr RBRACE
        { EFun(id, p, code, ENone) }
    | IF LPAREN v = value RPAREN LBRACE et = expr RBRACE LBRACE ef = expr RBRACE
        { EIf(v, et, ef, ENone) }
    | v = funcall SEMI
        { EApp(fst v, snd v, ENone) }
    | p = PRIM v = value
        { EPrim(p, v, ENone) }
    | v = value
        { EValue v }

value:
    | c = const
        { VConst(c) }
    | id = IDENT
        { VID(id) }
    | v1 = value o = op v2 = value
        { VOp(o, v1, v2) }
    | f = funcall
        { VApp(fst f, snd f) }
    | LPAREN p = product RPAREN
        { match p with
            | [v] -> v
            | p -> VProduct(p)
        }

product:
    | v = value
        { [v] }
    | v = value COMMA p = product
        { [v] @ p }

const:
    | n = NUM
        { CNum(n) }

plist:
    | id = IDENT
        { PList([Varname(id)]) }
    | id = IDENT COMMA p = plist
        { PList(Varname(id) :: unplist(p)) }

funcall:
    | v1 = value v2 = value
        { (v1, v2) }

op:
    | CAT
        { OCat}
    | PLUS
         {OPlus }
    | MINUS
        { OMinus }
    | TIMES
        { OTimes }
    | DIVIDE
        { ODivide }
    | LEQ
        { OLeq }
    | LESS
        { OLess }
    | GEQ
        { OGeq}
    | GREAT
        { OGreat }
    | EQ
        { OEq }
    | NEQ
        { ONeq}

