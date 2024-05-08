#!/bin/sh

# Check if you have a address created
if [ ! -f "./keys/payment.addr" ]; then
  echo "Please generate some keys and addresses before querying funds."
  echo "Exiting."
  exit 0
fi

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

echo "Querying UTXOs for your address: $(cat ./keys/payment.addr)"

# Query the UTxOs controlled by the payment address
container_cli query utxo \
  --address "$(cat ./keys/payment.addr)" \
  --testnet-magic 4 \
  --out-file  /dev/stdout