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

(* Question 4 *)

type bddNode =
| BddLeaf of int * bool
| BddNode of int * string * int * int;;

type bdd = (int * (bddNode list));; (* un entier pour designer le noeud racine et
la liste des noeuds *)