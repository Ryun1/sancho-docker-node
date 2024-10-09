#!/bin/sh

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

echo "Creating three keys to control a multi-sig script."

# Create directory for keys
mkdir -p ./keys/multi-sig

# Key 1
container_cli address key-gen \
 --verification-key-file keys/multi-sig/1.vkey \
 --signing-key-file keys/multi-sig/1.skey

container_cli address key-hash \
  --payment-verification-key-file keys/multi-sig/1.vkey > keys/multi-sig/1.keyhash

# Key 2
container_cli address key-gen \
 --verification-key-file keys/multi-sig/2.vkey \
 --signing-key-file keys/multi-sig/2.skey

container_cli address key-hash \
  --payment-verification-key-file keys/multi-sig/2.vkey > keys/multi-sig/2.keyhash

# Key 3
container_cli address key-gen \
 --verification-key-file keys/multi-sig/3.vkey \
 --signing-key-file keys/multi-sig/3.skey

container_cli address key-hash \
  --payment-verification-key-file keys/multi-sig/3.vkey > keys/multi-sig/3.keyhash

echo "Copying the script template."

cp ./scripts/multi-sig/multi-sig-template.json ./keys/multi-sig/script.json

echo "Adding keys to script."

# Remove \r from the key hashes when reading them
jq --arg kh1 "$(tr -d '\r' < ./keys/multi-sig/1.keyhash)" \
   --arg kh2 "$(tr -d '\r' < ./keys/multi-sig/2.keyhash)" \
   --arg kh3 "$(tr -d '\r' < ./keys/multi-sig/3.keyhash)" \
'.scripts[0].keyHash = $kh1 | .scripts[1].keyHash = $kh2 | .scripts[2].keyHash = $kh3' \
"./keys/multi-sig/script.json" > temp.json && mv temp.json "./keys/multi-sig/script.json"

echo "Creating script address."

cardano-cli address build \
  --testnet-magic 4 \
  --payment-script-file ./keys/multi-sig/script.json \
  --out-file ./keys/multi-sig/script.addr

echo "Done!"