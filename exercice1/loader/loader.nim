# Exercice 1 - Chargeur de shellcode de base
# Langage : Nim
# Objectif : démontrer l'exécution de code en mémoire sous windows
# Ce programme ne contient aucune persistance ni mécanisme d'évasion
 
when defined(windows):
  echo "loader initialisé"
else:
  echo "Ce programme est prévu pour Windows uniquement"

echo "loader prêt"

# Données factives, pas de shellcode
var payload: array[8, byte] = [byte 0x90, 0x90, 0x90, 0x09, 0xCC, 0x00, 0x00, 0x00]
echo "taille payload = ", payload.len

