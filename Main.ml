let p1 = Logique.Var "P1";;
let p2 = Logique.Var "P2";;
let q1 = Logique.Var "Q1";;
let q2 = Logique.Var "Q2";;
let f1 = Logique.Equivalent (q1, q2);;
let f2 = Logique.Equivalent (p1, p2);;
let ex1 = Logique.And (f1, f2);;

(* Question 1 *)

let rec getVars : Logique.tformula -> string list = fun f -> 
  match f with
  | Logique.Value x -> []
  | Logique.Var x -> [x]
  | Logique.Not x -> getVars x
  | Logique.And (x, y)
  | Logique.Or (x, y)
  | Logique.Implies (x, y)
  | Logique.Equivalent (x, y) -> List.sort compare ((getVars x) @ (getVars y))
;;

assert ((getVars ex1) = ["P1"; "P2"; "Q1"; "Q2"]);;
print_string "tout est bon\n";;

(* Question 2 *)

let rec getvalue : Logique.env -> string -> bool = fun v s -> 
  match v with
    | [] -> false
    | e::r -> let (x,y) = e in
      if (x = s) then
        y
      else (getvalue r s);;

      (*
let evalFormula : Logique.env -> Logique.tformula -> bool = fun v -> fun f ->
  match f with
    | Logique.Value x -> []
    | Logique.Var x -> [x]
    | Logique.Not x -> getVars x
    | Logique.And (x, y) -> List.sort compare ((getVars x) @ (getVars y))
    | Logique.Or (x, y) -> List.sort compare ((getVars x) @ (getVars y))
    | Logique.Implies (x, y) -> List.sort compare ((getVars x) @ (getVars y))
    | Logique.Equivalent (x, y) -> if 
    ;;
    *)