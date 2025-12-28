#Code pédagogique en Nim : Injecteur avec cible dynamique
#Code Block (nim)

# injecteur_cible_dynamique.nim
#Exercice pédagogique - recherche ou création dynamique d’un processus cible
import winim/lean

import osproc
import strutils

proc findProcessIdByName(procName: string): int =

var
snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
pe: PROCESSENTRY32
pe.dwSize = sizeof(PROCESSENTRY32)
if Process32First(snapshot, addr pe):
    while true:
        let name = $cast[cstring](pe.szExeFile)
        if cmpIgnoreCase(name, procName) == 0:
            CloseHandle(snapshot)
            return int(pe.th32ProcessID)
        if not Process32Next(snapshot, addr pe):
            break
CloseHandle(snapshot)
return 0  # 0 si non trouvé


proc createProcess(procPath: string): int =

var si: STARTUPINFO
var pi: PROCESS_INFORMATION
si.cb = sizeof(STARTUPINFO)
if CreateProcess(
    nil, cast[LPTSTR](procPath), nil, nil,
    FALSE, 0, nil, nil,
    addr si, addr pi
):
    echo "[+] Processus créé avec PID: ", pi.dwProcessId
    return int(pi.dwProcessId)
else:
    echo "[-] Impossible de créer le processus: ", procPath
    return 0


when isMainModule:

# Demande du nom de processus
echo "Nom du processus cible (ex: notepad.exe) : "
let procName = readLine(stdin)
var pid = findProcessIdByName(procName)

if pid == 0:
    echo "[!] Processus non trouvé, tentative de création..."
    pid = createProcess(procName)

if pid != 0:
    echo "[+] PID cible : ", pid
    # Ici on pourrais effectuer l'injection (simulation)
    echo "[SIMULATION] Injection dans le processus PID ", pid
else:
    echo "[-] Échec - aucun PID valide"