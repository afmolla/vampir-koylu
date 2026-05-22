#!/usr/bin/env bash
# CI / Linux: sabit release imzasi (PKCS12). Windows PFX yerine kullanilir.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KS="${ROOT}/signing/release.keystore"
PROPS="${ROOT}/key.properties"
PASS="${ANDROID_KEYSTORE_PASSWORD:-vampir_koylu_store}"
ALIAS="${ANDROID_KEY_ALIAS:-vampir}"

mkdir -p "${ROOT}/signing"

if [[ ! -f "$KS" ]]; then
  echo ">> Olusturuluyor: $KS"
  keytool -genkeypair -v \
    -keystore "$KS" \
    -alias "$ALIAS" \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -storepass "$PASS" \
    -keypass "$PASS" \
    -dname "CN=Vampir Koylu, OU=Mobile, O=Vampir, L=TR, ST=TR, C=TR" \
    -storetype PKCS12
else
  echo ">> Mevcut keystore: $KS"
fi

cat > "$PROPS" <<EOF
storePassword=${PASS}
keyPassword=${PASS}
keyAlias=${ALIAS}
storeFile=signing/release.keystore
storeType=PKCS12
EOF

echo ">> key.properties yazildi"
keytool -list -keystore "$KS" -storepass "$PASS" -storetype PKCS12 | head -5
