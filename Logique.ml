(* Question 1 *)

type tformula =
| Value of bool (* ⊥ ou � *)
| Var of string (* Variable *)
| Not of tformula (* Negation *)
| And of tformula * tformula (* Conjonction *)
| Or of tformula * tformula (* Disjonction *)
| Implies of tformula * tformula
| Equivalent of tformula * tformula (* Equivalence *);;

type decTree =
| DecLeaf of bool
| DecRoot of string * decTree * decTree;;

(* Question 2 *)

type env = (string*bool) list;;