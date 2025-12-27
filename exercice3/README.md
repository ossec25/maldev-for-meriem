Exercice 3, évasion antivirus de base
Objectif
Observer comment un binaire de type loader est traité par un antivirus, et quels éléments déclenchent une alerte.
Environnement
Machine utilisée.
OS Windows et version.
Version Nim.
Antivirus testé et configuration.
Build et exécution
Commande de compilation utilisée.
Commande d’exécution utilisée.
Résultat attendu.
Résultat obtenu.
Observations AV
Alerte affichée ou non.
Fichier bloqué ou non.
Quarantaine ou suppression.
Message exact si disponible.
Analyse
Ce qui semble déclencher l’alerte, d’après ce que tu observes.
Ce que tu retiens pour la suite.

J’ai créé un petit exemple Nim pour comprendre le principe du XOR sur des données non exécutables.
Le programme définit une fonction xorData qui applique XOR avec une clé sur une séquence de bytes.
Il chiffre une chaîne “Hello World!” encodée en bytes, puis la déchiffre avec la même clé.
Objectif: valider la logique de transformation réversible et la manipulation de données en mémoire, sans exécuter de code injecté.