# Exercice 2 : Injection de Shellcode à Distance

## Description

Cet exercice implémente un **injecteur de shellcode** qui injecte du code malveillant dans un processus Windows distant (par défaut `explorer.exe`).

Cette technique est couramment utilisée par les malwares pour :
- Échapper à la détection (le code s'exécute dans un processus légitime)
- Élever ses privilèges
- Persister dans le système

---

## Objectifs pédagogiques

- Comprendre l'architecture des processus Windows
- Manipuler la mémoire d'un processus distant
- Utiliser les API Windows pour l'injection de code
- Gérer les permissions et les handles

---

## Architecture technique

### **Étapes d'injection**
