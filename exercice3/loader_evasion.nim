# exercice3/loader_evasion.nim

proc xorData(data: seq[byte], key: byte): seq[byte] =
  result = newSeq[byte](data.len)
  for i, b in data:
    result[i] = b xor key

let dataPlain: seq[byte] = @[
  72'u8, 101'u8, 108'u8, 108'u8, 111'u8, 32'u8,
  87'u8, 111'u8, 114'u8, 108'u8, 100'u8, 33'u8
]

let key: byte = 0xAA'u8

let dataEncrypted = xorData(dataPlain, key)
echo "[+] Donnees chiffrées (XOR): ", dataEncrypted

let dataDecrypted = xorData(dataEncrypted, key)

var text = newString(dataDecrypted.len)
for i, b in dataDecrypted:
  text[i] = char(b)

echo "[+] Donnees dechiffrées: ", text
