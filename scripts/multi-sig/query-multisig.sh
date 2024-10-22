#!/bin/sh

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

echo "Querying UTXOs for your multisig script address: $(cat ./keys/multi-sig/script.addr)"

# Query the UTxOs controlled by multisig script address
container_cli conway query utxo \
  --address "$(cat ./keys/multi-sig/script.addr)" \
  --testnet-magic 4 \
  --out-file  /dev/stdout