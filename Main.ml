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

(* Question 2 *)

let rec getvalue : Logique.env -> string -> bool = fun v s -> 
  match v with
    | [] -> false
    | e::r -> let (x,y) = e in
      if (x = s) then
        y
      else (getvalue r s);;

assert ((getvalue ["P1",false;"P2",false;"Q1",false;"Q2",false] "Q2") = false);;

let rec evalFormula : Logique.env -> Logique.tformula -> bool = fun v f ->
  match f with
  | Logique.Value x -> x
  | Logique.Var x -> getvalue v x
  | Logique.Not x -> not (evalFormula v x)
  | Logique.And (x, y) -> (evalFormula v x) && (evalFormula v y)
  | Logique.Or (x, y) -> (evalFormula v x) || (evalFormula v y)
  | Logique.Implies (x, y) -> if ((evalFormula v x) && not (evalFormula v y)) then false else true
  | Logique.Equivalent (x, y) -> if ((evalFormula v x) = (evalFormula v y)) then true else false;;

assert ((evalFormula ["P1",false;"P2",false;"Q1",false;"Q2",false] ex1) = true);;

(* Question 3 *)

let rec buildDecTree : Logique.tformula -> Logique.decTree = fun f ->
  let variables = (getVars f) in
    match variables with
      | [] -> failwith "empty formula"
      | [e] -> Logique.DecRoot (e, (Logique.DecLeaf true), (Logique.DecLeaf false))
      | e::r -> Logique.DecRoot (e, (buildDecTree r), (buildDecTree r));;