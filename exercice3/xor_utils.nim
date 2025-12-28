
# ==============================================
# UTILITAIRES XOR POUR OBFUSCATION
# ==============================================

# --- Fonction de chiffrement/déchiffrement XOR ---
proc xorCrypt*(data: var openArray[byte], key: openArray[byte]) =
  ## Chiffre ou déchiffre des données avec XOR
  ## XOR est réversible : encrypt(encrypt(data)) = data
  
  for i in 0..<data.len:
    data[i] = data[i] xor key[i mod key.len]

# --- Générer une clé aléatoire ---
proc generateXorKey*(length: int): seq[byte] =
  ## Génère une clé XOR pseudo-aléatoire
  ## En production, utiliser un vrai générateur cryptographique
  
  result = newSeq[byte](length)
  
  # Utiliser le temps comme seed (simple mais suffisant pour demo)
  import times
  var seed = epochTime().int
  
  for i in 0..<length:
    seed = (seed * 1103515245 + 12345) and 0x7fffffff
    result[i] = byte(seed mod 256)

# --- Afficher des données en hexadécimal ---
proc toHexString*(data: openArray[byte], maxBytes: int = 16): string =
  ## Affiche les premiers bytes en format hex pour debug
  
  result = ""
  let limit = min(data.len, maxBytes)
  
  for i in 0..<limit:
    result.add($data[i].toHex())
    if i < limit - 1:
      result.add(" ")
  
  if data.len > maxBytes:
    result.add(" ...")