let p1 = Logique.Var "P1";;
let p2 = Logique.Var "P2";;
let q1 = Logique.Var "Q1";;
let q2 = Logique.Var "Q2";;
let f1 = Logique.Equivalent (q1, q2);;
let f2 = Logique.Equivalent (p1, p2);;
let ex1 = Logique.And (f1, f2);;

print_string "coucou Steeven\n";;