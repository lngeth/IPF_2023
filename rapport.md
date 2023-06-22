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
assert ((getVars ex1) = ["P1"; "P2"; "Q1"; "Q2"])

- (Q1 ⇔ Q2)
assert ((getVars f1) = ["Q1"; "Q2"])

- (P1 ⇔ P2)
assert ((getVars f2) = ["P1"; "P2"])

### Exercice 2

#### Fonctions + Interface

val evalFormula : env -> tformula -> bool

#### Cas de tests

### Exercice 3

#### Fonctions + Interface
#### Cas de tests

### Exercice 4

#### Fonctions + Interface
#### Cas de tests

### Exercice 5

#### Fonctions + Interface
#### Cas de tests

### Exercice 6

#### Fonctions + Interface
#### Cas de tests

### Exercice 7

#### Fonctions + Interface
#### Cas de tests
