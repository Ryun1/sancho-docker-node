#!/bin/sh

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

orchestrator_key_path="./keys/cc-manager/orchestrator"

# Check if you have a address created
if [ ! -f "./keys/payment.addr" ]; then
  echo "Please generate some orchestrator keys and addresses before querying funds."
  echo "Exiting."
  exit 0
fi

echo "\nQuerying UTxOs for your orchestrator address: $(cat $orchestrator_key_path/orchestrator.addr)"

echo "\nTable format:"

# Query the UTxOs controlled by the payment address in a table
container_cli query utxo \
  --address "$(cat $orchestrator_key_path/orchestrator.addr)" \
  --testnet-magic 4 \

# echo "\nJSON format:"

# # Query the UTxOs controlled by the payment address in a json format
# container_cli query utxo \
#   --address "$(cat $orchestrator_key_path/orchestrator.addr)" \
#   --testnet-magic 4 \
#   --out-file  /dev/stdout