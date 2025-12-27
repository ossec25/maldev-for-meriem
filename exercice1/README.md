\# Exercice 1 - chargeur de shellcode de base



Objectif :

Mettre en oeuvre un chargeur de shellcode simple permettant l'exécution de code en mémoire dans le processus courant.



\## Périmètre de l'exercice

cet exercice a pour but de comprendre le principe d'exécution de shellcode en mémoire dans un processus windows.



le travail se limite à :

* la génération de shellcode à des fins de démonstration
* l'étude des mécanismes execution en mémoire
* l'utilisation d'API windows documentées.



Aucun objectif de persistance, d'élévation de privilège ou de dissimulation avancée n'est poursuivi dans cet exercice.



\## Langage choisi



Le language utilisé pur le chargeur est Nim.



Ce choix est motivé par:

* Sa capacité à produire des binaires windows natifs
* Son interopérabilité avec l'API Windows
* La présence d'exemple et de format adaptés dans les supports du cours



Un shellcode est une suite d'octets représentant du code machine, conçue pur être exécutée directement en mémoire.
Dans le cadre de cet exercice, le shellcode est généré à des fins de démonstration et sert uniquement à illustrer le mécanisme d'exécution de code en mémoire sous windows.
Le shellcode est fourni sous un format compatible avec le langage utilisé, afin de pouvoir être intégré directement dans le programme chargeur.



\## Principe du chargeur de shellcode

Le chargeur de shellcode est un programme dont le rôle est :

* &nbsp;de préparer une zone mémoire adaptée
* De rendre cette zone exécutable
* De transférer l'exécution vers le shellcode



Le chargeur n'implémente aucune fonctionnalité de persistance ou d'évasion avancée, il se limite à démontrer les mécanismes fondamentaux d'exécution en mémoire.

* 
Validation du squelette

Dossier de travail
C:\repos\maldev-for-dummies\exercice1\loader

But
Vérifier que le squelette compile et que payload a une taille connue.

Commande
nim c loader.nim

Résultat attendu
Compilation réussie.
Affichage.
loader initialisé
loader prêt
taille payload = 8

Point Nim
payload est un array[8, byte]. Sa taille est fixe. payload.len renvoie 8.

Sortie réelle
loader initialisé
loader prêt
taille payload = 8
