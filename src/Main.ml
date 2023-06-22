open Logique;;

let p1 = Var "P1";;
let p2 = Var "P2";;
let q1 = Var "Q1";;
let q2 = Var "Q2";;
let f1 = Equivalent (q1, q2);;
let f2 = Equivalent (p1, p2);;
let ex1 = And (f1, f2);;

(* Question 1 *)

let rec getVars : tformula -> string list = fun f -> 
  match f with
  | Value x -> []
  | Var x -> [x]
  | Not x -> getVars x
  | And (x, y)
  | Or (x, y)
  | Implies (x, y)
  | Equivalent (x, y) -> List.sort compare ((getVars x) @ (getVars y))
;;

assert ((getVars ex1) = ["P1"; "P2"; "Q1"; "Q2"]);;
assert ((getVars f1) = ["Q1"; "Q2"]);;
assert ((getVars f2) = ["P1"; "P2"]);;

(* Question 2 *)

(* Evalue la formule avec les valueurs de chaque variable donnée dans un tableau env *)
let rec evalFormula : env -> tformula -> bool = fun v f ->
    match f with
    | Value x -> x
    | Var x -> 
        let rec getValue listEnv varToGet = (match listEnv with
            | [] -> false
            | e::r ->
                let (name, value) = e in
                    if (name = varToGet) then
                        value
                    else (getValue r varToGet))
            in (getValue v x)
    | Not x -> not (evalFormula v x)
    | And (x, y) -> (evalFormula v x) && (evalFormula v y)
    | Or (x, y) -> (evalFormula v x) || (evalFormula v y)
    | Implies (x, y) -> if ((evalFormula v x) && not (evalFormula v y)) then false else true
    | Equivalent (x, y) -> if ((evalFormula v x) = (evalFormula v y)) then true else false;;

assert ((evalFormula ["P1",false;"P2",false;"Q1",false;"Q2",false] ex1));;
assert (not (evalFormula ["P1",false;"P2",false;"Q1",false;"Q2",true] ex1));;
assert (not (evalFormula ["P1",false;"P2",false;"Q1",true;"Q2",false] ex1));;
assert ((evalFormula ["P1",false;"P2",false;"Q1",true;"Q2",true] ex1));;

(* Question 3 *)

let rec getDecTree : tformula -> string list -> env -> decTree = fun f -> fun l -> fun v ->
  match l with
    | [] -> failwith "empty tree"
    | [e] -> 
      let evalValueGauche = (evalFormula (v@[(e, false)]) f) in
        let evalValueDroit = (evalFormula (v@[(e, true)]) f) in
          DecRoot (e, DecLeaf evalValueGauche, DecLeaf evalValueDroit)
    | e::r -> 
      let newVGauche = (v@[(e, false)]) in
        let newVDroit = (v@[(e, true)]) in
          DecRoot (e, (getDecTree f r newVGauche), (getDecTree f r newVDroit));;
          
let buildDecTree : tformula -> decTree = fun f ->
  getDecTree f (getVars f) [];;

assert ((buildDecTree ex1) = (DecRoot ("P1",
DecRoot ("P2",
DecRoot ("Q1", DecRoot ("Q2", DecLeaf true, DecLeaf false),
DecRoot ("Q2", DecLeaf false, DecLeaf true)),
DecRoot ("Q1", DecRoot ("Q2", DecLeaf false, DecLeaf false),
DecRoot ("Q2", DecLeaf false, DecLeaf false))) ,
DecRoot ("P2",
DecRoot ("Q1", DecRoot ("Q2", DecLeaf false, DecLeaf false),
DecRoot ("Q2", DecLeaf false, DecLeaf false)),
DecRoot ("Q1", DecRoot ("Q2", DecLeaf true, DecLeaf false),
DecRoot ("Q2", DecLeaf false, DecLeaf true))))));;


(* Fonction test d'affichage de l'arbre decTree *)
let test_buildDecTree = (buildDecTree ex1) in
let rec print_buildDecTree : decTree -> unit = fun t ->
    (match t with
        | DecLeaf (b) -> Printf.printf ", %b" b
        | DecRoot (r, g, d) -> 
            Printf.printf "\nDecRoot (%s" r;
            print_buildDecTree g;
            print_buildDecTree d
    ) in print_buildDecTree test_buildDecTree
;;
  

(* Question 4 *)

(* Retourne le numéro du noeud spécifié en paramètre *)
let rec getNumOfSpecificBddNode : bddNode -> (bddNode list) -> int = fun n -> fun l ->
    match l with
        | [] -> 0
        | e::r -> match e with
            | BddLeaf (num, value) -> (match n with
                | BddLeaf (_, valueTc) ->
                    if (value = valueTc) then num
                    else 0 + (getNumOfSpecificBddNode n r)
                | BddNode (_, _, _, _) -> 0
                )
            | BddNode (num, name, g, d) -> (match n with
                | BddLeaf (_, _) -> 0 + (getNumOfSpecificBddNode n r)
                | BddNode (_, nameTc, gTc, dTc) ->
                    if ((name = nameTc) && (g = gTc) && (d = dTc)) then num
                   else 0 + (getNumOfSpecificBddNode n r)
                )
;;

assert ((getNumOfSpecificBddNode (BddLeaf (15, true)) [BddNode (10, "P1", 8, 9); BddNode (9, "P2", 7, 5);
BddNode (8, "P2", 5, 7); BddNode (7, "Q1" ,6 ,6);
BddNode (6, "Q2", 2, 2); BddNode (5, "Q1", 3 ,4);
BddNode (4, "Q2", 2, 1); BddNode (3, "Q2", 1, 2); BddLeaf (2 , false);
BddLeaf (1, true)]) = 1);;

(* Fonction qui vérifie si un bddNode est dans une liste de bddNode*)
let rec isBddNodeExist : bddNode -> (bddNode list) -> bool = fun n -> fun l ->
    match l with
        | [] -> false
        | e::r -> match e with
            | BddLeaf (_, value) -> (match n with
                | BddLeaf (_, valueTc) -> 
                    if (value = valueTc) then true 
                    else false || (isBddNodeExist n r)
                | BddNode (_, _, _, _) -> false || (isBddNodeExist n r))
            | BddNode (_, name, g, d) -> (match n with
                | BddLeaf (_, _) -> false || (isBddNodeExist n r)
                | BddNode (_, nameTc, gTc, dTc) ->
                    if (name = nameTc && g = gTc && d = dTc) then true
                    else false || (isBddNodeExist n r))
;;

assert ((isBddNodeExist (BddLeaf (1, true)) [BddNode (10, "P1", 8, 9); BddNode (9, "P2", 7, 5);
BddNode (8, "P2", 5, 7); BddNode (7, "Q1" ,6 ,6);
BddNode (6, "Q2", 2, 2); BddNode (5, "Q1", 3 ,4);
BddNode (4, "Q2", 2, 1); BddNode (3, "Q2", 1, 2); BddLeaf (2 , false);
BddLeaf (1, true)]) = true);;


(* Ajouter une bddNode à un bdd *)
let addBddNodeInList : bddNode -> bdd -> bdd = fun n -> fun b ->
    let _, actualList = b in
        match n with
            | BddLeaf (num, _) ->
                (num, ([n]@actualList))
            | BddNode (num, _, _, _) ->
                (num, ([n]@actualList))
;;

assert ((addBddNodeInList (BddLeaf (2 , false)) (1, [BddLeaf (1, true)])) = (2, [BddLeaf (2 , false);
BddLeaf (1, true)]));;

let getNewBdd : bddNode -> bdd -> (int * bdd) = fun n -> fun b ->
    let _, actualList = b in
    let numRes, finalBdd =
        (if (not (isBddNodeExist n actualList)) then (
            match n with
                | BddLeaf (numNode, valNode) -> (numNode, (addBddNodeInList n b))
                | BddNode (numNode, _, _, _) -> (numNode, (addBddNodeInList n b))
            )
        else ((getNumOfSpecificBddNode n actualList), b)) in
    (numRes, finalBdd)
;;

assert ((getNewBdd (BddLeaf (2 , false)) (1, [BddLeaf (1, true)])) = (2, ((2, [BddLeaf (2 , false);
BddLeaf (1, true)]):bdd)));;
assert ((getNewBdd (BddLeaf (1 , true)) (1, [BddLeaf (1, true)])) = (1, ((1, [BddLeaf (1, true)]):bdd)));;

let rec getBdd : tformula -> string list -> env -> bdd -> int * bdd = fun f -> fun l -> fun v -> fun b ->
    match l with
        | [] -> failwith "empty tree"
        | [e] ->
            let valGauche = evalFormula (v@[(e, false)]) f in
            let valDroit = evalFormula (v@[(e, true)]) f in
            
            let numInit, _ = b in
            let leafG = BddLeaf (numInit + 1, valGauche) in
            let numG, newBdd = (getNewBdd leafG b) in
            let numDprov = numG + 1 in
            let leafD = BddLeaf (numDprov, valDroit) in
            let numD, finalBdd = (getNewBdd leafD newBdd) in
            
            let numRoot, _ = finalBdd in
            let newNode = BddNode (numRoot + 1, e, numG, numD) in
            let nRes, resBdd = (getNewBdd newNode finalBdd) in
            (nRes, resBdd)
                
        | e::r ->
            let numG, bddG = (getBdd f r (v@[(e, false)]) b) in
            let numD, bddD = (getBdd f r (v@[(e, true)]) bddG) in
            let numRoot, _ = bddD in
            let numNode = numRoot + 1 in
            let newNode = BddNode (numNode, e, numG, numD) in
            let _, newList = bddD in
            let newBdd =
                (if (not (isBddNodeExist newNode newList)) then
                            (numNode, (addBddNodeInList newNode bddD))
                else 
                    ((getNumOfSpecificBddNode newNode newList), bddD)) in
            newBdd
;;

let buildBdd : tformula -> bdd = fun f ->
    let _, res = (getBdd f (getVars f) [] ((0, []):bdd)) in res
;;

assert ((buildBdd ex1) = (10,
[ BddNode (10, "P1", 8, 9); BddNode (9, "P2", 7, 5);
BddNode (8, "P2", 5, 7); BddNode (7, "Q1", 6, 6);
BddNode (6, "Q2", 2, 2); BddNode (5, "Q1", 3, 4);
BddNode (4, "Q2", 2, 1); BddNode (3, "Q2", 1, 2); BddLeaf (2, false);
BddLeaf (1, true)])
);;

(* Fonction pour afficher le BDD *)
let rec print_buildBdd: (bddNode list) -> unit = fun l ->
    match l with
        | [] -> Printf.printf "\n"
        | e::r -> (match e with
            | BddLeaf (num, value) ->
                Printf.printf "[%d, %b]\n" num value;
                print_buildBdd r
            | BddNode (num, name, g, d) -> 
                Printf.printf "[%d, %s, %d, %d]\n" num name g d;
                print_buildBdd r
            )
;;

let print_testBDD = buildBdd ex1 in
    let numRoot, l = print_testBDD in
    let _ = Printf.printf "\nNumRoot : %d\n" numRoot in
    
    print_buildBdd l
;;

(* Question 5 *)

(* numNodeRemoved = numéro du noeud enlevée
   numNodeSuccessor = numéro du sucesseur (fils gauche et droit pareil) du noeud à enlever
*)
let rec removeNodeFromList : bddNode -> (bddNode list) -> (int * int * (bddNode list)) = fun nodeTr -> fun l ->
    match l with
        | [] -> (0, 0, l)
        | e::r ->
            let numNodeRemoved, numNodeSuccessor, newList = (removeNodeFromList nodeTr r) in
            let newBddNode =
                if (not (numNodeRemoved = 0)) then
                    ( match e with
                        | BddLeaf (num, value) -> BddLeaf (num - 1, value)
                        | BddNode (num, name, g, d) ->
                            let newG, newD = 
                                if (g = numNodeRemoved) then (
                                    if (d = numNodeRemoved) then
                                        (numNodeSuccessor, numNodeSuccessor)
                                    else (numNodeSuccessor, d)
                                )
                                else (
                                    if (d = numNodeRemoved) then
                                        (g, numNodeSuccessor)
                                    else (g, d)
                                ) in
                            BddNode (num - 1, name, newG, newD)
                    )
                else e in
            (match newBddNode with
                | BddLeaf (num, value) -> (numNodeRemoved, numNodeRemoved, newBddNode::newList)
                | BddNode (num, name, g, d) -> (
                    match nodeTr with
                        | BddLeaf (_, _) -> (numNodeRemoved, numNodeRemoved, newBddNode::newList)
                        | BddNode (numTr, nameTr, gTr, dTr) ->
                            if (num = numTr && name = nameTr && g = gTr && d = dTr) then 
                            (numTr, dTr, newList)
                            else (numNodeRemoved, numNodeSuccessor, (newBddNode::newList))
                    )
            )
;;

assert((removeNodeFromList (BddNode (3, "Q2", 2, 2)) [BddNode (3, "Q2", 2, 2); BddLeaf (2, false); BddLeaf (1, true)]) = (3, 2, [BddLeaf (2, false); BddLeaf (1, true)]));;
assert((removeNodeFromList (BddNode (3, "Q2", 2, 2)) [BddNode (3, "Q2", 1, 2); BddLeaf (2, false); BddLeaf (1, true)]) = (0, 0, [BddNode (3, "Q2", 1, 2); BddLeaf (2, false); BddLeaf (1, true)]));;

let removeNodeFromBdd : bddNode -> (bddNode list) -> bdd = fun n -> fun l ->
    let _, _, newList = removeNodeFromList n l in
    (0, newList)
;;

let rec getSimplifiedBDD : (bddNode list) -> (bddNode list) -> (bool * bdd) = fun l -> fun modifiedList ->
    let numRoot = match modifiedList with
        | [] -> 0
        | e::r -> (match e with
            | BddLeaf (num, _) -> num
            | BddNode (num, _, _, _) -> num
            ) 
    in match l with
        | [] -> (false, (numRoot, modifiedList))
        | e::r ->
            ( match e with
                | BddLeaf (_, _) -> (false, (numRoot, modifiedList))
                | BddNode (_, _, g, d) ->
                    if (g == d) then (true, (removeNodeFromBdd e modifiedList))
                    else (getSimplifiedBDD r modifiedList)
            )
;;

let simplifyBDD : bdd -> bdd = fun b ->
    let _, bddNodeList = b in 
        let rec simplify l =
            let isChanged, newBdd = (getSimplifiedBDD l l) in
            (if (isChanged) then 
                let _, newList = newBdd in
                (simplify newList)
            else newBdd) in
    
    simplify bddNodeList
;;

assert ((simplifyBDD (buildBdd ex1)) = (8,
[ BddNode (8, "P1", 8, 9); BddNode (7, "P2", 2, 5); BddNode (6, "P2", 5, 2);
BddNode (5, "Q1", 3, 4); BddNode (4, "Q2", 2, 1); BddNode (3, "Q2", 1, 2);
BddLeaf (2, false); BddLeaf (1, true)])
);;

(* Test d'affichage de la bdd simplifiée *)
let test_simplifiedBdd = (simplifyBDD (buildBdd ex1)) in
    let numRoot, l = test_simplifiedBdd in 
    let _ = Printf.printf "Root : %d\n" numRoot in print_buildBdd l
;;

(* Question 6 *)

let isTautology : tformula -> bool = fun f ->
    let _, bddList = simplifyBDD (buildBdd f) in
    let rec checkTautology l =
        (match l with
            | [] -> 0
            | e::r -> (match e with
                | BddLeaf (_, value) ->
                    if (value) then
                        1 + (checkTautology r)
                    else
                        (-1) + (checkTautology r)
                | BddNode (_, _, _, _) -> 0 + (checkTautology r)
                )
        ) in
        ((checkTautology bddList) = 1)
;;

let exTautology = Equivalent (Implies (p1, q1), Or (Not p1, q1));; (*  (P ⇒ Q) ⇔ (¬P ∨ Q)   *)
assert ((isTautology exTautology) = true);;
assert ((isTautology ex1) = false);;

(* Question 7 *)

let areEquivalent : tformula -> tformula -> bool = fun fOne -> fun fTwo ->
    let _, listOne = simplifyBDD (buildBdd fOne) in
    let _, listTwo = simplifyBDD (buildBdd fTwo) in
        if ((List.length listOne) = (List.length listTwo)) then (
            let rec checkEachNode lOne lTwo =
                (match (lOne, lTwo) with
                    | ([], []) -> true
                    | ([], _::_) -> false
                    | (_::_, []) -> false
                    | (eO::rO, eT::rT) -> (match eO with
                        | BddLeaf (_, valueO) -> (match eT with
                            | BddLeaf (_, valueT) ->
                                if (valueO = valueT) then
                                    true && (checkEachNode rO rT)
                                else false
                            | BddNode (_, _, _, _) -> false
                            )
                        | BddNode (_, nameO, gO, dO) -> (match eO with
                            | BddLeaf (_, valueT) -> false
                            | BddNode (_, nameT, gT, dT) ->
                                if (nameO = nameT && gO = gT && dO = dT) then
                                    true && (checkEachNode rO rT)
                                else false
                            )
                        )
                )
            in (checkEachNode listOne listTwo)
        ) else false
;;

let exEquivalentP1 = Not (Not p1) in
    assert ((areEquivalent exEquivalentP1 p1) = true);;
    
let testEquivalenceET1 = And (p1, q1) in
let testEquivalenceET2 = And (q1, p1) in
    assert ((areEquivalent testEquivalenceET1 testEquivalenceET2) = true);;
