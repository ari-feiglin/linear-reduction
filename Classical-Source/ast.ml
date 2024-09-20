type state = string -> const

and expr =
    | ENone
    | ELet of var * value * expr
    | EFun of string * plist * expr * expr
    | EIf of value * expr * expr * expr
    | EApp of value * value * expr
    | EPrim of string * value * expr
    | EValue of value

and var = string * (value list)

and value =
    | VConst of const
    | VID of string
    | VOp of op * value * value
    | VApp of value * value
    | VProduct of value list

and closure = { mutable plist : plist; mutable code : expr; mutable state : state}

and const =
    | CNone
    | CNum of float
    | CProd of (const list)
    | CClosure of closure

and plist =
    | Varname of string
    | PList of plist list

and op =
    | OCat
    | OPlus
    | OMinus
    | OTimes
    | ODivide
    | OLeq
    | OGeq
    | OLess
    | OGreat
    | OEq
    | ONeq
;;

let unplist l = match l with PList l -> l | Varname v -> [Varname v];;

let rec pprint_const c =
    match c with
    | CNone -> "None"
    | CNum f -> Float.to_string f
    | CProd l -> List.fold_left (fun acc x -> acc ^ ", " ^ (pprint_const x)) "" l
    | CClosure _ -> "Closure"
;;

let pprint_op op =
    match op with
    | OCat -> "@"
    | OPlus -> "+"
    | OMinus -> "-"
    | OTimes -> "*"
    | ODivide -> "/"
    | OEq -> "=="
    | ONeq -> "!="
    | OLeq -> "<="
    | OGeq -> ">="
    | OLess -> "<"
    | OGreat -> ">"
;;

let rec pprint_value value =
    match value with
    | VConst (CNum f) -> Float.to_string f
    | VID s -> s
    | VOp (s, v1, v2) -> "(" ^ pprint_value v1 ^ ") " ^ pprint_op s ^ " (" ^ pprint_value v2 ^ ")"
    | VApp (v1, v2) -> "App(" ^ pprint_value v1 ^ ", " ^ pprint_value v2 ^ ")"
    | VProduct l -> List.fold_left (fun acc x -> acc ^ pprint_value x ^ ", ") "Product(" l ^ ")"
;;

let rec pprint_expr expr =
    match expr with
    | ENone -> "None"
    | ELet ((v,_),value,e) -> "ELet(" ^ v ^ ", " ^ pprint_value value ^ ", " ^ pprint_expr e ^ ")"
    | EFun (i,_,e1,e2) -> "EFun(" ^ i ^ ", " ^ pprint_expr e1 ^ ", " ^ pprint_expr e2 ^ ")"
    | EIf (v,et,ef,e) -> "EIf(" ^ ", " ^ pprint_expr et ^ ", " ^ pprint_expr ef ^ ", " ^ pprint_expr e ^ ")"
    | EApp (v1, v2, e) -> "EApp(" ^ pprint_value v1 ^ ", " ^ pprint_value v2 ^ ", " ^ pprint_expr e ^ ")"
    | EValue v -> "EValue(" ^ pprint_value v ^ ")"
    | EPrim (p, v, e) -> "EPrim(" ^ p ^ ", " ^ pprint_value v ^ ")"
;;

