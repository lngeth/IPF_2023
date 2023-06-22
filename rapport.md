# Rapport du projet de programmation fonctionnelle

Réalisé par **Laurent NGETH**.

## Structure du projet

Tous les types définis dans le projet est implémenter dans un fichier ***"Logique.ml"*** se trouvant dans le répertoire *src/utils*.  
Les types définis sont ainsi importer directement dans le fichier ***"Main.ml"*** grace à la directive **open** en haut du fichier.  
  
Tous les fichiers générés par la compilation, ainsi que l'éxécutable se trouve dans le répertoire **obj**.

## Explication du code

### Exercice 1

#### Fonctions + Interface

val **getVars** : tformula -> string list  
  
Retourne les variables d'une formule passée en paramètre, rangés par ordre alphabétique.

#### Cas de tests

- (Q1 ⇔ Q2) ∧ (P1 ⇔ P2) 

```ocaml
assert ((getVars ex1) = ["P1"; "P2"; "Q1"; "Q2"])
```

- (Q1 ⇔ Q2)

```ocaml
assert ((getVars f1) = ["Q1"; "Q2"])
```

- (P1 ⇔ P2)

```ocaml
assert ((getVars f2) = ["P1"; "P2"])
```

### Exercice 2

#### Fonctions + Interface

val evalFormula : env -> tformula -> bool  
  
Cette fonction retourne la valeur de la formule évaluée en prenant en paramètre les valeurs de chaque variable contenus dans un tableau de tuple (type env).  

#### Cas de tests

On utilise la formule suivante, contenu dans la variable *ex1*, pour les tests : (Q1 ⇔ Q2) ∧ (P1 ⇔ P2).  
  
- "P1" = false ; "P2" = false ; "Q1" = false ; "Q2" = false

(false ⇔ false) ∧ (false ⇔ false) => doit retourner True  
```ocaml
assert ((evalFormula ["P1",false;"P2",false;"Q1",false;"Q2",false] ex1))  
```
  
- "P1" = false ; "P2" = false ; "Q1" = false ; "Q2" = true

(false ⇔ True) ∧ (false ⇔ false) => doit retourner False  
```ocaml
assert (not (evalFormula ["P1",false;"P2",false;"Q1",false;"Q2",true] ex1))  
```
  
- "P1" = false ; "P2" = false ; "Q1" = true ; "Q2" = false

(True ⇔ False) ∧ (false ⇔ false) => doit retourner False  
```ocaml
assert (not (evalFormula ["P1",false;"P2",false;"Q1",true;"Q2",false] ex1))  
```
  
- "P1" = false ; "P2" = false ; "Q1" = true ; "Q2" = true

(True ⇔ True) ∧ (false ⇔ false) => doit retourner False  
```ocaml
assert ((evalFormula ["P1",false;"P2",false;"Q1",true;"Q2",true] ex1))
```

### Exercice 3

#### Fonctions + Interface

- val getDecTree : tformula -> string list -> env -> decTree  
- val buildDecTree : tformula -> decTree  
  
buildDecTree() est utilisé une fonction qui permet de générer un arbre descendant représentant une formule logique à partir d'une formule donnée en paramètre.  
Pour la mettre en place, j'ai créer une fonction intermédiaire getDecTree(), qui est récursive et permet de construire un à un les noeuds de l'arbre.  
Il prend en paramètre la formule à évaluer, le tableau des noms des variables obtenus avec getVars et un tableau avec les valeurs booléennes (type env) de chaque variables.  
  
La méthode consiste à parcourir la liste des tableaux de variables de la formule et tant qu'on n'a pas atteint le dernier élément du tableau, nous allons créer un DecRoot gauche et un DecRoot droit avec tout deux comme noeud la variable courant du tableau de variables qu'on est en train de parcourir.  
Le DecRoot gauche prendra la valeur de retour d'un appel récursif à la même fonction mais avec le tableau *env* avec un ajout d'un tuple correspond au noeud courant avec une valeur de False. Pareil pour le DecRoot droit mais l'appel récursif prendra un tableau *env* avec un tuple de la valeur courante à True.  

Dès qu'on attend le dernier élément du tableau, on ne fait plus d'appel récursif. On créer un DecRoot avec comme fils gauche un DecLeaf avec une valeur correspondant à l'évaluation de la formule avec les valeurs du tableau *env* passée en paramètre en plus d'un tuple à Faux en plus (valeur du dernier noeud). Et en fils droit, il aura également un DecLeaf avec une évaluation de la formule avec un tuple à Vrai en plus.

On évalue donc la formule **uniquement après avoir atteint la dernière variable** de la formule. Cela nous permet ainsi d'obtenir un arbre descendant avec toutes les valeurs possibles de pour chaque noeud, ainsi que l'évaluation de la formule qui lui est associée.

- val print_buildDecTree : decTree -> unit

Cette **fonction n'est pas demandé** mais je l'ai créer afin de faire des tests d'affichages de l'arbre.  
Elle prend ainsi un decTree en paramètre et l'affiche dans le terminal.

#### Cas de tests

- Arbre de la formule : (Q1 ⇔ Q2) ∧ (P1 ⇔ P2)
  
Construction de l'arbre à partir de la formule.
```ocaml
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
DecRoot ("Q2", DecLeaf false, DecLeaf true))))))
```

### Exercice 4

#### Fonctions + Interface

Pour réussir à créer une bdd à partir d'une formule, j'ai dû créer plusieurs fonctions intermédiaires.

- val getNumOfSpecificBddNode : bddNode -> bddNode list -> int

Fonction qui retourne le numéro du bddNode passé en 1er paramètre dans une liste de bddNode passé en second paramètre. Retourne 0 si le bddNode n'est pas dans la liste.  
La comparaison se fait pour la valeur booléenne pour un BddLeaf.  
Pour un BddNode, la comparaison se fait sur le nom de variable du noeud, le numéro du fifs gauche et du fils droit.  
  
- val isBddNodeExist : bddNode -> bddNode list -> bool

Vérifie si un bddNode se trouve dans une liste de bddNode. Retourne True si oui, Faux sinon.

- val addBddNodeInList : bddNode -> bdd -> bdd

Ajoute un bddNode dans un bdd. Ici, je ne fais qu'ajouter le bddNode dans la liste de bddNode se trouvant dans la bdd passé en paramètre.  
Je ne shift pas les numéros des bddNodes existant car j'ajoute le bddNode au début de la liste et de ce fait, son numéro sera le nouveau "root" de la bdd.

- val getNewBdd : bddNode -> bdd -> int * bdd

Cette fonction s'occupe d'essayer d'ajouter une bddNode dans une bdd.  
On fait donc une vérification si ce bddNode existe déjà dans la liste de bddNode de bdd (appelle à la fonction isBddNodeExist()) puis si la bddNode n'existe pas encore, alors on utilise la fonction d'ajout addBddNodeInList(), on renvoie donc le numéro de la bddNode qui vient d'être ajouté ainsi que la nouvelle bdd.  
Si la bddNode existe déjà, on l'a récupère avec la fonction getNumOfSpecificBddNode() et on renvoie son numéro de bddNode avec la même bdd (qui n'a pas changée).

- val getBdd : tformula -> string list -> env -> bdd -> int * bdd

C'est la fonction récursive qui s'occupe de parcourir la liste des variables de la formule et qui s'occupe de générer la bdd.  
Pour faire simple, on parcourt chaque variable de la formule et on créer un BddNode gauche et droit dont les valeurs correspondront à des appels récursives sur le reste du tableau de variable de la formule.  
Dès qu'on atteint le dernier élément du tableau, on évalue la formule avec le tableau de *env* passé en paramètre et on créer un BddLeaf gauche avec comme dernière valeur False et un BddLeaf droit qui aura True.  
Dès lors, on tente d'ajouter les BddLeaf s'ils n'existent pas avec la fonction définie en haut, getNewBdd(). La récursivité va remonter les appels un à un, et procède la même manière en appelant getNewBdd() pour chaque BddNode.  
  
À la fin, on obtient la bdd représentant la formule passée en paramètre.

- val buildBdd : tformula -> bdd

C'est la fonction demandé par l'enseignant, qui va appelé la fonction récursive en haut, getBdd(), qui va se charger de créer la bdd à partir d'une formule passé en paramètre.

- val print_buildBdd : bddNode list -> unit

Fonction pour afficher dans la console la bdd.

#### Cas de tests

- getNumOfSpecificBddNode() :

Récupérer la valeur d'un BddLeaf avec une valeur de True.
```ocaml
assert ((getNumOfSpecificBddNode (BddLeaf (15, true)) [BddNode (10, "P1", 8, 9); BddNode (9, "P2", 7, 5);
BddNode (8, "P2", 5, 7); BddNode (7, "Q1" ,6 ,6);
BddNode (6, "Q2", 2, 2); BddNode (5, "Q1", 3 ,4);
BddNode (4, "Q2", 2, 1); BddNode (3, "Q2", 1, 2); BddLeaf (2 , false);
BddLeaf (1, true)]) = 1)
```
=> Doit retourner 1

- isBddNodeExist() :

Vérifie s'il existe un BddLeaf avec une valeur de True.  
```ocaml
assert ((isBddNodeExist (BddLeaf (1, true)) [BddNode (10, "P1", 8, 9); BddNode (9, "P2", 7, 5); 
BddNode (8, "P2", 5, 7); BddNode (7, "Q1" ,6 ,6); BddNode (6, "Q2", 2, 2); 
BddNode (5, "Q1", 3 ,4); BddNode (4, "Q2", 2, 1); BddNode (3, "Q2", 1, 2); 
BddLeaf (2 , false); BddLeaf (1, true)]) = true)
```
=> Retourne True

- addBddNodeInList() :

```ocaml
assert ((addBddNodeInList (BddLeaf (2 , false)) (1, [BddLeaf (1, true)])) = (2, [BddLeaf (2 , false); BddLeaf (1, true)]))
```

- getNewBdd() :

1. Ajoute de *BddLeaf (2 , false)* -> doit pouvoir être ajouté

```ocaml
assert ((getNewBdd (BddLeaf (2 , false)) (1, [BddLeaf (1, true)])) = (2, ((2, [BddLeaf (2 , false); BddLeaf (1, true)]):bdd)))
```

2. Ajoute de *BddLeaf (1 , true)* -> ne doit pas pouvoir être ajouté

```ocaml
assert ((getNewBdd (BddLeaf (1 , true)) (1, [BddLeaf (1, true)])) = (1, ((1, [BddLeaf (1, true)]):bdd)))
```

- getBdd() avec buildBdd() :
  
Doit construire la forme bdd de la formule : (Q1 ⇔ Q2) ∧ (P1 ⇔ P2)  

```ocaml
assert ((buildBdd ex1) = (10,
[ BddNode (10, "P1", 8, 9); BddNode (9, "P2", 7, 5); BddNode (8, "P2", 5, 7); BddNode (7, "Q1", 6, 6); BddNode (6, "Q2", 2, 2); BddNode (5, "Q1", 3, 4); BddNode (4, "Q2", 2, 1); BddNode (3, "Q2", 1, 2); BddLeaf (2, false); BddLeaf (1, true)]))
```

### Exercice 5

#### Fonctions + Interface

- val removeNodeFromList : bddNode -> bddNode list -> int * int * bddNode list
  
Fonction qui permet de supprimer un bddNode d'une (bddNode list).  
Il retourne également le noeud du bddNode à supprimer ainsi que son fils gauche et droit qui sont censés être les mêmes.  
**On n'utilise cette fonction uniquement pour supprimer un bddNode dont le fils gauche et droit sont les mêmes**, sinon cette fonction n'a pas lieu d'être.

- val removeNodeFromBdd : bddNode -> bddNode list -> bdd

Fonction intermédiaire qui appelle la fonction removeNodeFromList, qui est récursive, permettant de supprimer un noeud d'une bdd passée en paramètre.

- val getSimplifiedBDD : bddNode list -> bddNode list -> bool * bdd

Fonction intermédiaire à simplifyBDD, qui est récursive et qui s'occupe de parcourir la liste de bddNode et à supprimer tous les bddNode qui ont les mêmes fils gauche et droit.  
Si on en supprime un, on décale tous les numéros de bddNode de hauteur supérieur.  
On remplace également tous les numéros des bddNodes supprimés par ceux de leur fils.

- val simplifyBDD : bdd -> bdd

Fonction qui prend un bdd en paramètre et la simplifie, en enlevant les bddNode ayant le même fils gauche et droit.

#### Cas de tests

- Pour removeNodeFromList() :

  - Enlever *BddNode (3, "Q2", 2, 2)* doit pouvoir se faire -> retourne le numéro du noeud supprimer, le numéro du fils droit et gauche (sont les mêmes) et la nouvelle liste avec le noeud en moins.
  ```ocaml
  assert((removeNodeFromList (BddNode (3, "Q2", 2, 2)) [BddNode (3, "Q2", 2, 2); BddLeaf (2, false); BddLeaf (1, true)]) = (3, 2, [BddLeaf (2, false); BddLeaf (1, true)]))
  ```

  - Enlever *BddNode (3, "Q2", 2, 2)* ne doit pas pouvoir se faire car il n'est pas présent dans la liste. On retourne donc 0, 0 et la même liste.
  ```ocaml
  assert((removeNodeFromList (BddNode (3, "Q2", 2, 2)) [BddNode (3, "Q2", 1, 2); BddLeaf (2, false); BddLeaf (1, true)]) = (0, 0, [BddNode (3, "Q2", 1, 2); BddLeaf (2, false); BddLeaf (1, true)]))
  ```

- Pour getSimplifiedBDD et simplifyBDD :

La bdd générer par la fonction créer dans l'exercice 4 (buildBdd) va être simplifier.  
On doit passer de 10 noeuds à 8 noeuds, avec une bonne numérotation.
```ocaml
assert ((simplifyBDD (buildBdd ex1)) = (8,
[ BddNode (8, "P1", 8, 9); BddNode (7, "P2", 2, 5); BddNode (6, "P2", 5, 2);
BddNode (5, "Q1", 3, 4); BddNode (4, "Q2", 2, 1); BddNode (3, "Q2", 1, 2);
BddLeaf (2, false); BddLeaf (1, true)])
)
```

### Exercice 6

#### Fonctions + Interface

- val isTautology : tformula -> bool

Fonction qui vérifie si une formule est une tautologie.  
Pour faire cela, on génère d'abord la bdd de la formule avec la fonction buildBdd, puis on la simplifie avec simplifyBDD.  
Ensuite on parcourt la liste de la bdd obtenue et si à la fin du parcours, on ne trouve pas de BddLeaf avec une valeur de *false*, alors cela signifie que cette formule est une tautologie.  
Sinon, ce n'est pas une tautologie.

#### Cas de tests

- (Q1 ⇔ Q2) ∧ (P1 ⇔ P2)

Il existe plusieurs cas où cette formule est fausse. On le vérifie en trouvant un BddLeaf à *false* dans la bdd simplifiée obtenue.
```ocaml
assert ((isTautology ex1) = false)
```

- (P ⇒ Q) ⇔ (¬P ∨ Q)

La formule doit toujours être vraie, c'est une tautologie.
```ocaml
let exTautology = Equivalent (Implies (p1, q1), Or (Not p1, q1))
assert ((isTautology exTautology) = true)
```

### Exercice 7

#### Fonctions + Interface

- val areEquivalent : tformula -> tformula -> bool

Vérifie si 2 formules passées en paramètre sont équivalentes.  
Pour faire cela, on génère les 2 bdd simplifiées des 2 formules, puis on parcourt conjointement les listes de bddNode des 2 listes.  
Si les 2 listes ont une taille différente, c'est certain qu'elles ne sont pas égales et donc qu'elles ne sont pas équivalentes.  
Si les 2 listes ont la même taille mais qu'il existe une seule différence bddNode, alors elles ne sont pas équivalentes. Sinon, elles sont équivalentes.

#### Cas de tests

- ¬(¬p1) et p1

La négation d'une négation s'annule. Ces 2 formules sont donc équivalentes.
```ocaml
let exEquivalentP1 = Not (Not p1) in
    assert ((areEquivalent exEquivalentP1 p1) = true);;
```

- (p1 ∧ q1) et (q1 ∧ p1)

L'ordre des variables ici n'a pas d'importance. Ces 2 formules doivent donc être équivalentes.
```ocaml
let testEquivalenceET1 = And (p1, q1) in
let testEquivalenceET2 = And (q1, p1) in
    assert ((areEquivalent testEquivalenceET1 testEquivalenceET2) = true);;
``` 
