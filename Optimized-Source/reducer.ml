type parameters = { mutable silent : bool; mutable recursion_depth : int; }

let parameters : parameters = { silent = false; recursion_depth = 0; }

type printable_term = string;;

type value =
    | None
    | NumVal of float
    | PreOpVal of ((value * value) -> value)
    | OpVal of value * (value * value -> value)
    | POpVal of (value -> value) * (value * value -> value)
    | ListVal of value list
    | LetVal of printable_term * (int list)
    | PrimVal of ((type_term * value) -> (type_term * value))
    | VarNameVal of printable_term
    | CodeVal of printable_term list
    | FunVal of printable_term * value
    | ClosureVal of closure
    | IfVal of float * (printable_term list)
    | SwitchVal of (float * (printable_term list)) list
    | TypeVal of type_term

and closure = {
    plist : value;
    code : printable_term list;
    mutable state : partial_state;
}

and partial_state = printable_term -> pi_i

and type_term =
    | None
    | Num
    | List of type_term
    | Closure
    | Product of (type_term list)
    | String
    | Primitive
    | Type of type_term

and abstract_term =
    | None
    | Gobble
    | Match of type_term
    | End
    | Op of type_term
    | POp
    | Lparen
    | Rparen of type_term
    | Lbrack of type_term
    | Rbrack
    | Period
    | Index
    | Let
    | Letvar
    | Leteq
    | Equal
    | Comma of (type_term list)
    | Listrparen of (type_term list)
    | Lbrace
    | Rbrace
    | AltLparen
    | AltLbrace
    | Code
    | Fun
    | Funname
    | Funvars
    | Plist
    | Bar
    | Guard
    | Arrow
    | GuardArrow
    | SwitchSegment
    | ConstEnd
    | Switch
    | If
    | IfBool
    | IfVar
    | IfThen
    | Colon
    | Typer of type_term

and term =
    | None
    | PTerm of printable_term
    | TTerm of type_term
    | ATerm of abstract_term

and term_i =
    | None
    | TTerm of type_term
    | ATerm of abstract_term

and pi_i = term_i * value

and pi =
    | Pi_I of pi_i
    | PTerm of printable_term
;;

let rec tterm_to_str (t : type_term) =
    match t with
    | None -> "None"
    | Num -> "Num"
    | List(t) -> "List{" ^ (tterm_to_str t) ^ "}"
    | Product l -> "Product{" ^ (List.fold_left (fun acc x -> (acc ^ (tterm_to_str x) ^ " ")) "" l) ^ "}"
    | Closure -> "Closure"
    | Primitive -> "Primitive"
    | Type t -> "Type{" ^ (tterm_to_str t) ^ "}"
;;


let aterm_to_str (t : abstract_term) =
    match t with
    | None -> "None"
    | Gobble -> "Gobble"
    | Match(t) -> "Match{" ^ (tterm_to_str t) ^ "}"
    | End -> "End"
    | Op(t) -> "Op{" ^ (tterm_to_str t) ^ "}"
    | POp -> "POp"
    | Lparen -> "Lparen"
    | Rparen(t) -> "Rparen{" ^ (tterm_to_str t) ^ "}"
    | Lbrack(t) -> "Lbrack{" ^ (tterm_to_str t) ^ "}"
    | Rbrack -> "Rbrack"
    | Period -> "Period"
    | Index -> "Index"
    | Let -> "Let"
    | Letvar -> "Letvar"
    | Leteq -> "Leteq"
    | Equal -> "Equal"
    | Comma l -> "Comma{" ^ (List.fold_left (fun acc x -> (acc ^ (tterm_to_str x) ^ " ")) "" l) ^ "}"
    | Listrparen l -> "Rparen{" ^ (List.fold_left (fun acc x -> (acc ^ (tterm_to_str x) ^ " ")) "" l) ^ "}"
    | Lbrace -> "Lbrace"
    | Rbrace -> "Rbrace"
    | AltLparen -> "AltLparen"
    | AltLbrace -> "AltLbrace"
    | Code -> "Code"
    | Fun -> "Fun"
    | Funname -> "Funname"
    | Funvars -> "Funvars"
    | Plist -> "Plist"
    | Bar -> "Bar"
    | Guard -> "Guard"
    | Arrow -> "Arrow"
    | GuardArrow -> "GuardArrow"
    | SwitchSegment -> "SwitchSegment"
    | ConstEnd -> "ConstEnd"
    | Switch -> "Switch"
    | If -> "If"
    | IfBool -> "IfBool"
    | IfVar -> "IfVar"
    | IfThen -> "IfThen"
    | Colon -> "Colon"
    | Typer t -> "Typer{" ^ (tterm_to_str t) ^ "}"
;;

let rec _list_to_str f l =
    match l with
    | [] -> "]"
    | [x] -> (f x) ^ "]"
    | t :: l -> (f t) ^ ", " ^ (_list_to_str f l)
;;

let list_to_str f l =
    "[" ^ (_list_to_str f l)
;;

let rec value_to_str v =
    match v with
    | None -> ""
    | NumVal(f) -> Float.to_string f
    | PreOpVal(f) -> "fun"
    | OpVal(v,f) -> (value_to_str v) ^ " fun"
    | POpVal (f,g) -> "f, g"
    | ListVal(l) -> list_to_str value_to_str l
    | LetVal (v,l) -> v ^ (List.fold_left (fun acc x -> acc ^ " " ^ (string_of_int x)) "" l)
    | PrimVal _ -> "prim"
    | VarNameVal s -> s
    | CodeVal l -> List.fold_left (fun acc x -> acc ^ " " ^ x) "" l
    | FunVal (x, v) -> x ^ ", " ^ (value_to_str v)
    | ClosureVal c -> "<" ^ (value_to_str (c.plist)) ^ ", code, state>"
    | IfVal (n,l) -> "<" ^ (Float.to_string n) ^ " code>"
    | SwitchVal l -> List.fold_left (fun acc (n,c) -> acc ^ " <" ^ (Float.to_string n) ^ " code>>") "" l
    | TypeVal t -> tterm_to_str t
;;

class extnum (v : int) (isinf : bool) =
    object(self)
        method value = v
        method infty = isinf
        method geq (other : extnum) : bool =
            if (self#infty && self#value >= 0) || (other#infty && other#value < 0) then true
            else if not other#infty && self#value >= other#value then true
            else false
        method str =
            if self#infty then if self#value < 0 then "-infty" else "infty"
            else string_of_int (self#value)
    end
;;

type priority = extnum;;

let initial_priority s =
    try int_of_string s; new extnum 0 true
    with Failure _ -> (
        match s with
        | ";" -> new extnum (-1) true
        | "=" -> new extnum (-1) true
        | "(" -> new extnum 0 true
        | ")" -> new extnum 0 false
        | "+" -> new extnum 1 false
        | "*" -> new extnum 2 false
        | "-" -> new extnum 1 true
        | "/" -> new extnum 2 false
        | "@" -> new extnum 1 false
        | "==" -> new extnum 0 false
        | "!=" -> new extnum 0 false
        | "<=" -> new extnum 0 false
        | ">=" -> new extnum 0 false
        | ">" -> new extnum 0 false
        | "<" -> new extnum 0 false
        | "[" -> new extnum 0 false
        | "]" -> new extnum 0 false
        | "." -> new extnum 0 true
        | "," -> new extnum 0 false
        | "{" -> new extnum 0 true
        | "}" -> new extnum 0 true
        | "|" ->  new extnum 0 false
        | "->" ->  new extnum 0 true
        (* | "_prim_print" -> new extnum (-1) true *)
        | _ -> new extnum 0 true
    )
;;

let rec initial_priorities (str : string list) : ((pi * priority) list) =
    match str with 
    | [] -> []
    | s :: str -> (PTerm s, initial_priority s) :: (initial_priorities str)
;;

let rec valuate_stack (stack : partial_state list) (x : printable_term) : pi_i =
    match stack with
    | [] -> raise (Failure ("printable term " ^ x ^ " does not exist in stack"))
    | t :: stack -> (
        try t x with
        | Failure _ -> valuate_stack stack x
    )
;;

class state =
    object(self)
        val mutable pstate_stack = ([] : partial_state list)
        val mutable closure_stack = ([0] : int list)
        val mutable depth = 0
        method push pstate =
            pstate_stack <- pstate :: pstate_stack;
            depth <- depth + 1;
            self
        method push_closure pstate =
            closure_stack <- depth :: closure_stack;
            self#push pstate
        method pop = (
            (match pstate_stack with
            | [] -> raise (Invalid_argument "Empty state stack")
            | ps :: stack -> (pstate_stack <- stack;
                pstate_stack <- stack;
                depth <- depth - 1;
            )
            );
            (try (if List.hd closure_stack = depth then
                closure_stack <- List.tl closure_stack)
            with
            | Failure _ -> ());
            self
        )
        method set_top pstate =
            pstate_stack <- pstate :: (List.tl pstate_stack)
        method alter pstate =
            let top = List.hd pstate_stack in
            let new_top = fun x -> (
                try pstate x with
                | Failure _ -> top x
            ) in
            self#set_top new_top;
            self
        method alter_var x v =
            let pstate = fun y -> if x = y then v else raise (Failure "Not defined") in
            self#alter pstate
        method valuate x =
            valuate_stack pstate_stack x
        method close =
            let i = (List.length closure_stack) - (List.hd closure_stack) in
            let rec helper stack i y = (
                if i < 0 then raise (Failure ("Variable " ^ y ^ " not in partial state"))
                else (
                    match stack with
                    | [] -> raise (Failure ("Variable " ^ y ^ " not in partial state"))
                    | ps :: stack -> (
                        try ps y with
                        | Failure _ -> helper stack (i-1) y
                    )
                )
            ) in helper pstate_stack i
    end
;;

let unvaluelist v =
    match v with
    | ListVal l -> l
    | _ -> raise (Invalid_argument "Cannot unvalue something which is not a list")
;;

let rec swap_list (l : value) (ns : int list) (x : value) =
    match l, ns with
    | _, [] -> x
    | ListVal [], _ -> raise (Invalid_argument "Cannot give an empty list")
    | ListVal (k :: l), t :: ns -> (
        if t = 0 then
            ListVal ((swap_list k ns x) :: l)
        else
            ListVal (k :: (unvaluelist (swap_list (ListVal l) ((t - 1) :: ns) x)))
    )
;;

let let_new_state (state : state) (s : term_i) (x : printable_term) (v : value) (ns : int list) : partial_state =
    if s = None then raise (Invalid_argument "Cannot put None value in state")
    else if ns = [] then
        fun y -> (
            if y = x then (s, v)
            else raise (Failure "not defined")
        )
    else
        let old_val = state#valuate x in
        let kappa = snd old_val in
        let new_kappa = swap_list kappa ns v in
        fun y -> (
            if y = x then ((fst old_val), new_kappa)
            else raise (Failure "not defined")
        )
;;

let rec find_guard (l : (float * printable_term list) list) : printable_term list =
    match l with
    | [] -> []
    | (0.0,xi) :: l -> find_guard l
    | (n,xi) :: l -> xi
;;

let tterm_val_to_pi_i ((tterm, u) : type_term * value) : pi_i =
    (TTerm tterm, u)
;;

let rec create_pstate (plist : value) (u : value) (sigma : type_term) : partial_state =
    let rec helper (plist : value) (u : value) (sigma : type_term) (y : printable_term) = (
        match plist with
        | VarNameVal x | ListVal [VarNameVal x] -> if x = y then (sigma, u) else raise (Failure ("Variable " ^ y ^ " not in partial state"))
        | ListVal l -> (
            match l,u,sigma with
            | [],_,_ -> raise (Failure ("Cannot find variable " ^ y ^ " in partial state"))
            | [x; z], ListVal ([u1;u2]), Product([sigma1; sigma2]) -> (
                try helper x u1 sigma1 y with
                | Failure _ -> helper z u2 sigma2 y
            )
            | x :: l, ListVal (u1::u), Product (sigma1 :: sigma) -> (
                try helper x u1 sigma1 y with
                | Failure _ -> helper (ListVal l) (ListVal u) (Product sigma) y
            )
        )
    ) in fun y -> ((helper plist u sigma y) |> tterm_val_to_pi_i)
;;

let term_i_to_term (t : term_i) : term =
    match t with
    | None -> None
    | TTerm s -> TTerm s
    | ATerm s -> ATerm s
;;

let term_to_term_i (t : term) : term_i =
    match t with
    | None -> None
    | TTerm s -> TTerm s
    | ATerm s -> ATerm s
    | PTerm s -> raise (Failure "Cannot convert printable term to term_i")
;;

let zero = fun (n,m) -> new extnum 0 false;;
let one = fun (n,m) -> new extnum 1 false;;
let infty = fun (n,m) -> new extnum 0 true;;
let minfty = fun (n,m) -> new extnum (-1) true;;

let alt_pstate y : pi_i = match y with
    | "{" -> (ATerm AltLbrace, CodeVal [])
    | "(" -> (ATerm AltLparen, ListVal [])
    | _ -> raise (Failure ("Pterm " ^ y ^ " not in partial state"))
;;

let compound_type (sigma : type_term) (tau : type_term) =
    match sigma with
    | None -> raise (Failure "Cannot compound None type")
    | Num ->  raise (Failure "Cannot compound Num type")
    | List None -> List tau
    | List _ -> raise (Failure "Cannot compound already compound type")
    | Closure ->  raise (Failure "Cannot compound Closure type")
    | Product [] -> Product [tau]
    | Product _ -> raise (Failure "Cannot compound already compound type")
    | String ->  raise (Failure "Cannot compound String type")
    | Primitive ->  raise (Failure "Cannot compound Primitive type")
    | Type None -> Type tau
    | Type _ -> raise (Failure "Cannot compound already compound type")
;;

let rec untype (omega : type_term list) =
    match omega with
    | [] -> []
    | Type t :: omega -> t :: (untype omega)
    | _ -> raise (Failure "Cannot untype non-Type'd term")
;;

let compound_types (sigma : type_term) (omega : type_term list) =
    match sigma with
    | None -> raise (Failure "Cannot compound None type")
    | Num ->  raise (Failure "Cannot compound Num type")
    | List _ -> raise (Failure "Cannot compound unary compound type with multiple types")
    | Closure ->  raise (Failure "Cannot compound Closure type")
    | Product [] -> Product (untype omega)
    | Product _ -> raise (Failure "Cannot compound already compound type")
    | String ->  raise (Failure "Cannot compound String type")
    | Primitive ->  raise (Failure "Cannot compound Primitive type")
    | Type _ -> raise (Failure "Cannot compound unary compound type with multiple types")
;;

let rec initial_beta (first : term_i) (second : term) :
    (term_i * (extnum * extnum -> extnum) * (value * value * state -> value * (printable_term list) * state)) =
    match first, second with
    (* End *)
    | sigma, ATerm End -> (sigma, minfty, fun (u,_,s) -> (u,[],s))
    (* Operators *)
    | ATerm POp, TTerm sigma -> (TTerm sigma, snd, fun (POpVal (f,g), u, s) -> (f u, [], s))
    | TTerm sigma, ATerm POp -> (ATerm (Op sigma), one, fun (u, POpVal (f,g), s) -> (OpVal(u,g),[],s))
    | ATerm POp, ATerm (Rparen sigma) -> (ATerm (Rparen sigma), snd, fun (POpVal (f,g), u, s) -> (f u, [], s))
    | TTerm sigma, ATerm (Op None) -> (ATerm (Op sigma), snd, fun (u,PreOpVal f,s) -> (OpVal(u,f),[],s))
    | ATerm (Op sigma), ATerm (Op tau) -> (
        if sigma = tau then
            (ATerm (Op sigma), snd, fun (OpVal(u,f), OpVal(v,g), s) -> (OpVal(f(u,v),g), [], s))
        else
            raise (Failure "Cannot match operators with different types")
    )
    | ATerm (Op sigma), TTerm tau -> (
        if sigma = tau then
            (TTerm sigma, snd, fun (OpVal(u,f), v, s) -> (f(u,v), [], s))
        else
            raise (Failure "Cannot match operator with different type")
    )
    (* Parentheses *)
    | TTerm sigma, ATerm (Rparen None) -> (ATerm (Rparen sigma), snd, fun (u,_,s) -> (u,[],s))
    | ATerm (Op sigma), ATerm (Rparen tau) -> (
        if sigma = tau then
            (ATerm (Rparen sigma), snd, fun (OpVal(u,f), v, s) -> (f(u,v), [], s))
        else
            raise (Failure "Cannot match operator with rparen of different type")
    )
    | ATerm POp, ATerm (Rparen sigma) -> (ATerm (Rparen sigma), snd, fun (POpVal (f,g), u,s) -> (f u, [], s))
    | ATerm Lparen, ATerm (Rparen sigma) -> (TTerm sigma, fst, fun (_,u,s) -> (u,[],s))
    (* Lists *)
    | ATerm (Lbrack None), TTerm sigma -> (ATerm (Lbrack sigma), fst, fun (_,u,s) -> (ListVal [u],[],s))
    | ATerm (Lbrack sigma), TTerm tau -> (
        if sigma = tau then
            (ATerm (Lbrack sigma), fst, fun (ListVal l,u,s) -> (ListVal (l @ [u]), [], s))
        else
            raise (Failure "Cannot match list building element with different type")
    )
    | ATerm (Lbrack sigma), ATerm Rbrack -> (TTerm (List sigma), infty, fun (l,_,s) -> (l, [], s))
    | ATerm Period, TTerm Num -> (ATerm Index, zero, fun (_, n, s) -> (n, [], s))
    | TTerm (List sigma), ATerm Index -> (TTerm sigma, fst, fun (ListVal l, NumVal i, s) -> (List.nth l (int_of_float i), [], s))
    (* Variables *)
    | ATerm Let, PTerm x -> (ATerm Letvar, snd, fun (_,_,s) -> (LetVal (x,[]), [], s))
    | ATerm Letvar, ATerm Index -> (ATerm Letvar, fst, fun (LetVal (x,l), NumVal n, s) -> (LetVal (x, l@[int_of_float n]), [], s))
    | ATerm Letvar, ATerm Equal -> (ATerm Leteq, minfty, fun (u,_,s) -> (u, [], s))
    | ATerm Leteq, TTerm sigma -> (None, fst, fun (LetVal (x,l), u, s) -> None, [], s#alter (let_new_state s (TTerm sigma) x u l))
    (* Scoping *)
    | ATerm Lbrace, None -> (None, fst, fun (_,_,s) -> (None, [], s#push (fun x -> raise (Failure "Empty state"))))
    | ATerm Rbrace, None -> (None, fst, fun (_,_,s) -> (None, [], s#pop))
    (* Products *)
    | TTerm sigma, ATerm (Comma []) -> (ATerm (Comma [sigma]), snd, fun (u,_,s) -> (ListVal [u], [], s))
    | ATerm (Op sigma), ATerm (Comma [tau]) -> (
        if sigma = tau then
            (ATerm (Comma [sigma]), snd, fun (OpVal (u,f), ListVal [v], s) -> (ListVal [f(u,v)], [], s))
        else
            raise (Failure "Cannot match operator of one type with comma of another")
    )
    | ATerm POp, ATerm (Comma [sigma]) -> (ATerm (Comma [sigma]), snd, fun (POpVal (f,g), u, s) -> (f u, [], s))
    | ATerm (Comma omega), ATerm (Comma [sigma]) -> (ATerm (Comma (omega @ [sigma])), snd, fun (ListVal l1, ListVal l2, s) -> (ListVal (l1 @ l2), [], s))
    | ATerm (Comma omega), ATerm (Rparen sigma) -> (ATerm (Listrparen (omega @ [sigma])), snd, fun (ListVal l, v, s) -> (ListVal (l @ [v]), [], s))
    | ATerm Lparen, ATerm (Listrparen omega) -> (TTerm (Product omega), infty, fun (_, ListVal l, s) -> (ListVal l, [], s))
    (* Primitives *)
    | TTerm Primitive, TTerm sigma -> (
        (None, fst, fun (PrimVal f, v, s) -> (let res = f (sigma, v) in let t_i = fst res in let value = snd res in (None, [], (s#alter_var "_reg_out" (TTerm t_i, value)))))
    )
    (* Code Capture *)
    | ATerm AltLbrace, PTerm "}" -> (ATerm Code, infty, fun (xi,_,s) -> (xi, [], s))
    | ATerm AltLbrace, PTerm "{" -> raise (Failure "Cannot match { with {")
    | ATerm AltLbrace, PTerm x -> (ATerm AltLbrace, infty, fun (CodeVal xi,_,s) -> (CodeVal (xi @ [x]), [], s))
    | ATerm AltLbrace, ATerm Code -> (ATerm AltLbrace, infty, fun (CodeVal xi1, CodeVal xi2, s) -> (CodeVal (xi1 @ ["{"] @ xi2 @ ["}"]), [], s))
    (* Parameter Capture *)
    | ATerm AltLparen, PTerm ")" -> (ATerm Plist, fst, fun (l,_,s) -> (l,[],s))
    | ATerm AltLparen, PTerm "(" -> raise (Failure "Cannot match ( with (")
    | ATerm AltLparen, PTerm "," -> (ATerm AltLparen, fst, fun (l,_,s) -> (l, [], s))
    | ATerm AltLparen, PTerm x -> (ATerm AltLparen, fst, fun (ListVal l,_,s) -> (ListVal (l @ [VarNameVal x]), [], s))
    | ATerm AltLparen, ATerm Plist -> (ATerm AltLparen, fst, fun (ListVal l,u,s) -> (ListVal (l @ [u]), [], s))
    (* Function Definitions *)
    | ATerm Fun, PTerm x -> (ATerm Funname, infty, fun (_,_,s) -> (FunVal (x, None), [], s#push alt_pstate))
    | ATerm Funname, ATerm Plist -> (ATerm Funvars, infty, fun (FunVal (x, None), u, s) -> (FunVal (x,u), [], s))
    | ATerm Funvars, ATerm Code -> (None, fst, fun (FunVal (x,u), CodeVal l, s) -> (
        s#pop;
        let clos = { plist = u; code = l; state = fun _ -> raise (Failure "You should not be seeing this");} in
        s#alter_var x (TTerm Closure, ClosureVal clos);
        clos.state <- s#close;
        (ClosureVal clos, [], s)
    ))
    | TTerm Closure, TTerm sigma -> (None, fst, fun (ClosureVal clos, u, s) -> (
        let pstate = create_pstate (clos.plist) u sigma in
        (None, clos.code @ ["}"], (s#push_closure (clos.state))#alter pstate)
    ))
    (* If *)
    | ATerm If, TTerm sigma -> (
        let pstate y : pi_i = (match y with
        | "{" -> (ATerm AltLbrace, CodeVal [])
        | "(" -> (ATerm AltLparen, ListVal [])
        | _ -> raise (Failure ("Pterm " ^ y ^ " not in partial state"))
        ) in (ATerm IfBool, fst, fun (_,NumVal n,s) -> (IfVal (n,[]), [], s#push pstate))
    )
    | ATerm IfBool, ATerm Code -> (ATerm IfThen, fst, fun (IfVal (n,[]), CodeVal l, s) -> (IfVal (n, l), [], s))
    | ATerm IfThen, ATerm Code -> (None, fst, fun (IfVal (n,c1), CodeVal c2, s) -> (None, (if n = 0. then c2 else c1), s#pop))
    (* Switch *)
    | TTerm Num, ATerm Arrow -> (TTerm Num, zero, fun (u,_,s) -> (u,[],s#push alt_pstate))
    | ATerm Bar, TTerm Num -> (ATerm Guard, infty, fun (_,NumVal n,s) -> (SwitchVal [(n,[])], [], s))
    | ATerm Guard, ATerm Code -> (ATerm SwitchSegment, infty, fun (SwitchVal [(n,[])], CodeVal xi, s) -> (SwitchVal [(n,xi)], [], s#pop))
    | ATerm SwitchSegment, ATerm SwitchSegment -> (ATerm SwitchSegment, infty, fun (SwitchVal l1, SwitchVal l2, s) -> (SwitchVal (l1 @ l2), [], s))
    | ATerm SwitchSegment, ATerm ConstEnd -> (ATerm ConstEnd, infty, fun (u, _, s) -> (u, [], s))
    | ATerm Switch, ATerm ConstEnd -> (None, infty, fun (_, SwitchVal l, s) -> (None, find_guard l, s))
    (* Types *)
    | TTerm (Type sigma), TTerm (Type tau) -> let ctype = compound_type sigma tau in (TTerm (Type ctype), snd, fun (_,_,s) -> (TypeVal ctype, [], s))
    | TTerm (Type sigma), TTerm (Product omega) -> let ctype = compound_types sigma omega in (TTerm (Type ctype), snd, fun (_,_,s) -> (TypeVal ctype, [], s))
    | ATerm Colon, TTerm (Type sigma) -> (ATerm (Typer sigma), snd, fun (_,u,s) -> (u, [], s))
    | TTerm _, ATerm (Typer sigma) -> (TTerm sigma, fst, fun (u,_,s) -> (u, [], s))
;;

type pi_priority = pi * priority;;

let rec copy_str s n =
    if n > 0 then
        s ^ (copy_str s (n-1))
    else
        ""
;;

let first3 (x,y,z) = x;;
let second3 (x,y,z) = y;;
let third3 (x,y,z) = z;;

exception Cant_match

let rec try_initial (first : term_i) (first_val : value) (first_priority : priority) (second : term) (second_val : value) (second_priority : priority) (tokens : pi_priority list) (state : state) =
    let ib = initial_beta first second in
    let new_term = first3 ib in
    let priority_function = second3 ib in
    let value_function = third3 ib in
    let new_priority = priority_function (first_priority, second_priority) in
    let new_values = value_function (first_val, second_val, state) in
    let new_value = first3 new_values in
    let printable_string = second3 new_values in
    let new_state = third3 new_values in
    let tb = (
        if printable_string <> [] then (
            parameters.recursion_depth <- parameters.recursion_depth + 1;
            let res = total_beta (initial_priorities printable_string) new_state in
            parameters.recursion_depth <- parameters.recursion_depth - 1;
            res
        )
        else
            ([], new_state)
    ) in
    let new_tokens = fst tb in
    let new_state = snd tb in
    if new_term = None then (
        (new_tokens @ tokens, new_state, true)
    )
    else (
        (new_tokens @ [((Pi_I (new_term, new_value), new_priority))] @ tokens, new_state, true)
    )

and derived_beta (tokens, state : pi_priority list * state) : (pi_priority list * state * bool) =
    (if not parameters.silent then (print_string (copy_str "\t" (parameters.recursion_depth)); print_tokens (tokens, state)));
    match tokens with
    | [] -> [], state, false
    | (PTerm x, n) :: tokens -> ((Pi_I (state#valuate x), n) :: tokens, state, true)
    | (Pi_I (t,u), n) :: toks -> (
        try try_initial t u n None None n toks state with
        | Match_failure _ | Failure _ -> (
            match toks with
            | [] -> (tokens, state, false)
            | (Pi_I (s,v), m) :: toksA -> (
                if n#geq m then
                    try try_initial t u n (term_i_to_term s) v m toksA state with
                    | Match_failure _ | Failure _ -> (
                        let next = derived_beta (toks, state) in
                        let toks = first3 next in
                        let state = second3 next in
                        let b = third3 next in
                        if b then derived_beta ((Pi_I (t, u), n) :: toks, state)
                        else ((Pi_I (t, u), n) :: toks, state, false)
                    )
                else 
                    let next = derived_beta (toks, state) in
                    let toks = first3 next in
                    let state = second3 next in
                    let b = third3 next in
                    if b then derived_beta ((Pi_I (t, u), n) :: toks, state)
                    else ((Pi_I (t, u), n) :: toks, state, false)
            )
            | (PTerm x, m) :: toksA -> (
                if n#geq m then
                    try try_initial t u n (PTerm x) None m toksA state with
                    | Match_failure _ | Failure _ -> (
                        let next = derived_beta (toks, state) in
                        let toks = first3 next in
                        let state = second3 next in
                        let b = third3 next in
                        if b then derived_beta ((Pi_I (t, u), n) :: toks, state)
                        else ((Pi_I (t, u), n) :: toks, state, false)
                    )
                else
                    let next = derived_beta (toks, state) in
                    let toks = first3 next in
                    let state = second3 next in
                    let b = third3 next in
                    if b then derived_beta ((Pi_I (t, u), n) :: toks, state)
                    else ((Pi_I (t, u), n) :: toks, state, false)
            )
        )
    )

and print_tokens (str,state : pi_priority list * state) =
    match str with
    | [] -> print_endline ""
    | (PTerm t, n) :: str -> print_string (t ^ "_" ^ (n#str) ^ " "); print_tokens (str, state)
    | (Pi_I (TTerm t, v), n) :: str -> print_string ((tterm_to_str t) ^ "_" ^ (n#str) ^ "(" ^ (value_to_str v) ^ ") "); print_tokens (str,state)
    | (Pi_I (ATerm t, v), n) :: str -> print_string ((aterm_to_str t) ^ "_" ^ (n#str) ^ "(" ^ (value_to_str v) ^ ") "); print_tokens (str,state)
    | (Pi_I (None, v), n) :: str -> print_string "None "; print_tokens (str, state)

and total_beta (str : pi_priority list) (state : state) =
    (*(if not parameters.silent then (print_string (copy_str "\t" (parameters.recursion_depth)); print_tokens (str, state)));*)
    let res = derived_beta (str, state) in
    let str = first3 res in
    let state = second3 res in
    let continue = third3 res in
    if continue then (
        try total_beta str state with
        | Cant_match -> (str, state)
    ) else (str, state)
    (*if str != [] then (
        try total_beta str state with
        | Cant_match -> (str, state)
    ) else
        (str, state)*)
;;

let bool_to_num b = if b then 1. else 0.;;

let initial_state (x : printable_term) : pi_i =
    try (TTerm Num, NumVal(Float.of_string x))
    with Failure _ -> (
        match x with
        | ";" -> (ATerm End, None)
        | ":" -> (ATerm Colon, None)
        | "(" -> (ATerm Lparen, None)
        | ")" -> (ATerm (Rparen None), None)
        | "+" -> (ATerm (Op None), PreOpVal (fun (NumVal n, NumVal m) -> NumVal(n+.m)))
        | "*" -> (ATerm (Op None), PreOpVal (fun (NumVal n, NumVal m) -> NumVal(n*.m)))
        | "-" -> (ATerm (POp), POpVal ((fun (NumVal n) -> NumVal(-.n)), (fun (NumVal n, NumVal m) -> NumVal(n-.m))))
        | "/" -> (ATerm (Op None), PreOpVal (fun (NumVal n, NumVal m) -> NumVal(n/.m)))
        | "@" -> (ATerm (Op None), PreOpVal (fun (ListVal l1, ListVal l2) -> ListVal (l1 @ l2)))
        | "==" -> (ATerm (Op None), PreOpVal (fun (n, m) -> NumVal(n = m |> bool_to_num)))
        | "!=" -> (ATerm (Op None), PreOpVal (fun (n, m) -> NumVal(n <> m |> bool_to_num)))
        | "<=" -> (ATerm (Op None), PreOpVal (fun (NumVal n, NumVal m) -> NumVal(n <= m |> bool_to_num)))
        | ">=" -> (ATerm (Op None), PreOpVal (fun (NumVal n, NumVal m) -> NumVal(n >= m |> bool_to_num)))
        | "<" -> (ATerm (Op None), PreOpVal (fun (NumVal n, NumVal m) -> NumVal(n < m |> bool_to_num)))
        | ">" -> (ATerm (Op None), PreOpVal (fun (NumVal n, NumVal m) -> NumVal(n > m |> bool_to_num)))
        | "[" -> (ATerm (Lbrack None), ListVal [])
        | "]" -> (ATerm Rbrack, None)
        | "." -> (ATerm Period, None)
        | "|" -> (ATerm Bar, None)
        | "->" -> (ATerm Arrow, None)
        | "let" -> (ATerm Let, None)
        | "=" -> (ATerm Equal, None)
        | "_prim_print" -> (TTerm Primitive, PrimVal (fun (a,v) -> (print_endline (value_to_str v); (None, None))))
        | "_prim_len" -> (TTerm Primitive, PrimVal (fun (a,ListVal l) ->  (Num, NumVal (l |> List.length |> float_of_int))))
        | "_prim_tail" -> (TTerm Primitive, PrimVal (fun (sigma,ListVal (h :: t)) ->  (sigma, ListVal t)))
        | "_prim_type" -> (TTerm Primitive, PrimVal (fun (sigma,_) -> (Type sigma, TypeVal sigma)))
        | "," -> (ATerm (Comma []), None)
        | "{" -> (ATerm Lbrace, None)
        | "}" -> (ATerm Rbrace, None)
        | "fun" -> (ATerm Fun, None)
        | "if" -> (ATerm If, None)
        | "switch" -> (ATerm Switch, None)
        | "end" -> (ATerm ConstEnd, SwitchVal [])
        | "Num" -> (TTerm (Type Num), TypeVal Num)
        | "List" -> (TTerm (Type (List None)), TypeVal (List None))
        | "Closure" -> (TTerm (Type Closure), TypeVal Closure)
        | "Product" -> (TTerm (Type (Product [])), TypeVal (Product []))
        | "String" -> (TTerm (Type String), TypeVal String)
        | "Primitive" -> (TTerm (Type Primitive), TypeVal Primitive)
        | "Type" -> (TTerm (Type (Type None)), TypeVal (Type None))
        | _ -> raise (Failure "Printable term not found in state")
    )
;;

let state = new state;;
state#push initial_state;;

