#!/usr/bin/env bash
# SABIT imza — repodaki release.keystore / release.pfx (YENI anahtar URETMEZ).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KS="${ROOT}/signing/release.keystore"
PFX="${ROOT}/signing/release.pfx"
FP="${ROOT}/signing/SIGNING_FINGERPRINT.txt"
PASS="${ANDROID_KEYSTORE_PASSWORD:-vampir_koylu_store}"
ALIAS="${ANDROID_KEY_ALIAS:-vampir}"
EXPECTED_FP="9D:A3:64:84:D1:BA:19:3A:C0:5A:CA:C4:2A:56:73:29:49:D9:37:4C:B7:9E:D6:73:D5:E6:49:51:7A:78:62:B6"

if [[ ! -f "$KS" ]]; then
  if [[ ! -f "$PFX" ]]; then
    echo "FATAL: signing/release.keystore veya release.pfx repoda yok."
    exit 1
  fi
  echo ">> release.keystore yok; release.pfx'ten import (tek kaynak)..."
  SRC_ALIAS=$(keytool -list -keystore "$PFX" -storepass "$PASS" -storetype PKCS12 2>/dev/null \
    | awk -F, '/PrivateKeyEntry/{gsub(/^ +| +$/,"",$1); print $1; exit}')
  keytool -importkeystore -noprompt \
    -srckeystore "$PFX" -srcstoretype PKCS12 -srcstorepass "$PASS" \
    -srcalias "$SRC_ALIAS" \
    -destkeystore "$KS" -deststoretype PKCS12 -deststorepass "$PASS" \
    -destkeypass "$PASS" -destalias "$ALIAS"
fi

# SHA256 satiri "9D:A3:..." — awk -F: ile bolunurse yanlis parca alinir
ACTUAL=$(keytool -list -v -keystore "$KS" -storepass "$PASS" -storetype PKCS12 -alias "$ALIAS" 2>/dev/null \
  | sed -n 's/^[[:space:]]*SHA256:[[:space:]]*//p' | head -1 \
  | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')
EXPECTED_CLEAN=$(echo "$EXPECTED_FP" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')

if [[ "$ACTUAL" != "$EXPECTED_CLEAN" ]]; then
  echo "FATAL: Imza parmak izi degisti! Beklenen: $EXPECTED_FP"
  echo "Gercek: $ACTUAL"
  echo "Yeni keystore URETME — release.keystore dosyasini geri al."
  exit 1
fi

cat > "$FP" <<EOF
# Vampir Koylu — KALICI release imzasi (degistirme)
# Alias: $ALIAS
# SHA-256: $EXPECTED_FP
EOF

cat > "${ROOT}/key.properties" <<EOF
storePassword=${PASS}
keyPassword=${PASS}
keyAlias=${ALIAS}
storeFile=signing/release.keystore
storeType=PKCS12
EOF

echo ">> Sabit imza OK (alias=$ALIAS)"
keytool -list -keystore "$KS" -storepass "$PASS" -storetype PKCS12 -alias "$ALIAS" | head -3
