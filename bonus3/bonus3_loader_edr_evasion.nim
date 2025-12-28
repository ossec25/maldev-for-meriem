import winim/lean
import strformat
import times

when not defined(windows):
  {.error: "Ce programme nécessite Windows".}

proc demoDelay(ms: int) =
  echo fmt"[*] Démo délai: {ms} ms (pédagogique)"
  let t0 = epochTime()
  Sleep(cast[DWORD](ms))
  let t1 = epochTime()
  echo fmt"[+] Temps mesuré ≈ {int((t1 - t0) * 1000)} ms"

proc demoRwToRxNoExec(dataLen: int): bool =
  echo fmt"[*] Démo mémoire RW puis changement de protection (sans exécution), taille={dataLen}"
  let mem = VirtualAlloc(nil, cast[SIZE_T](dataLen), MEM_COMMIT or MEM_RESERVE, PAGE_READWRITE)
  if mem == nil:
    echo fmt"[-] VirtualAlloc a échoué. err={GetLastError()}"
    return false
  defer:
    discard VirtualFree(mem, 0, MEM_RELEASE)
    echo "[*] Mémoire libérée"

  var fake: array[8, byte] = [byte 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88]
  copyMem(mem, addr fake[0], min(dataLen, fake.len))
  echo "[+] Octets factices copiés en mémoire RW"

  var oldProtect: DWORD
  let ok = VirtualProtect(mem, cast[SIZE_T](dataLen), PAGE_READONLY, addr oldProtect)
  if ok == 0:
    echo fmt"[-] VirtualProtect a échoué. err={GetLastError()}"
    return false

  echo fmt"[+] Protection changée: ancien=0x{oldProtect:X}, nouveau=PAGE_READONLY. Aucune exécution."
  return true

when isMainModule:
  echo "========================================="
  echo "  BONUS 3 SAFE - démo timings et mémoire"
  echo "========================================="

  demoDelay(500)

  if demoRwToRxNoExec(8):
    quit(0)
  quit(1)
