import winim/lean
import strformat

when not defined(windows):
  {.error: "Ce programme nécessite Windows".}

type
  DemoFunc = proc() {.cdecl.}

var payload: array[8, byte] = [
  byte 0xFC, 0x48, 0x83, 0xE4,
  0xF0, 0xE8, 0xC0, 0x00
]

proc demoPointerCast[I](data: array[I, byte]): bool =
  echo "[*] Démo pointer casting, sans exécution"
  let mem = VirtualAlloc(nil, cast[SIZE_T](I), MEM_COMMIT or MEM_RESERVE, PAGE_READWRITE)
  if mem == nil:
    echo "[-] VirtualAlloc a échoué. err=", GetLastError()
    return false
  defer:
    discard VirtualFree(mem, 0, MEM_RELEASE)
    echo "[*] Mémoire libérée"

  copyMem(mem, unsafeAddr data[0], I)
  let f = cast[DemoFunc](mem)
  discard f
  echo fmt"[+] Cast effectué vers un type proc (adresse 0x{cast[int](mem):X}), aucune exécution"
  return true

when isMainModule:
  discard demoPointerCast(payload)
