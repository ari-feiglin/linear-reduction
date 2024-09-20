open Ast;;

let rec add_variables state p c =
    match p,c with
    | PList [Varname v], c -> (
        fun x -> (if v = x then c else state x)
    )
    | Varname v, c -> (
        fun x -> (if v = x then c else state x)
    )
    | p,c -> (
        let rec helper p c x = 
            match p,c with
            | PList [], _ | _, CProd [] -> state x
            | PList (Varname v :: p), CProd (c1 :: c) -> (
                if v = x then c1
                else helper (PList p) (CProd c) x
            )
        in helper p c
    )
;;

let add_variable state v indices c =
    let helper x = (
        if x = v then c
        else state x
    ) in helper
;;

let bool_to_float b =
    if b then 1.
    else 0.
;;

let operate o c1 c2 =
    match o, c1, c2 with
    | OCat, _,_ -> raise (Invalid_argument "Lists not implemented")
    | OPlus, CNum n, CNum m -> CNum (n +. m)
    | OMinus, CNum n, CNum m -> CNum (n -. m)
    | OTimes, CNum n, CNum m -> CNum (n *. m)
    | ODivide, CNum n, CNum m -> CNum (n /. m)
    | OEq, c1, c2 -> CNum(bool_to_float (c1 = c2))
    | ONeq, c1, c2 -> CNum(bool_to_float (c1 <> c2))
    | OLeq, CNum n, CNum m -> CNum(bool_to_float (n <= m))
    | OGeq, CNum n, CNum m -> CNum(bool_to_float (n >= m))
    | OLess, CNum n, CNum m -> CNum(bool_to_float (n < m))
    | OGreat, CNum n, CNum m -> CNum(bool_to_float (n > m))
    | _, _, _ -> raise (Invalid_argument "Invalid operator")
;;

let rec apply c1 c2 =
    match c1 with
    | CClosure clos -> (
        let state = add_variables (clos.state) (clos.plist) c2 in
        eval_expr (clos.code) state
    )
    | _ -> raise (Invalid_argument "Cannot apply non-closure")

and eval_value (value : value) (state : state) : const =
    match value with
    | VConst c -> c
    | VID s -> state s
    | VOp (o, v1, v2) -> operate o (eval_value v1 state) (eval_value v2 state)
    | VApp (v1, v2) -> apply (eval_value v1 state) (eval_value v2 state) |> fst
    | VProduct l -> CProd (List.map (fun v -> eval_value v state) l)

and eval_expr (expr : expr) (state : state) : (const * state) =
    match expr with
    | ENone -> (CNone, state)
    | ELet ((v, indices), value, expr) -> (
        let state = add_variable state v indices (eval_value value state) in
        eval_expr expr state
    )
    | EFun (id, params, code, expr) -> (
        let clos : closure = {plist=params; code=code; state=state} in
        let state = add_variable state id [] (CClosure clos) in (* Fix closure *)
        clos.state <- state;
        eval_expr expr state
    )
    | EIf (cond, et, ef, expr) -> (
        let res = (if eval_value cond state = CNum 0. then
            eval_expr ef state
        else
            eval_expr et state
        ) in
        if expr <> ENone then
            eval_expr expr (snd res)
        else
            res
    )
    | EApp (v1, v2, expr) -> (
        let res = apply (eval_value v1 state) (eval_value v2 state) in
        if expr <> ENone then
            eval_expr expr state
        else
            res
    )
    | EPrim (p, v, expr) -> (
        let c = eval_value v state in
        match p with
        | "_prim_print" -> print_endline (pprint_const c); eval_expr expr state
        | _ -> raise (Invalid_argument ("Invalid primitive " ^ p))
    )
    | EValue v -> (eval_value v state, state)
;;

