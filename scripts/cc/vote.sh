#!/bin/sh

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

# Function to display script usage
usage() {
  echo "Usage: $0 <choice> <ga_id>"
  echo "Example: $0 yes 66cbbf693a8549d0abb1b5219f1127f8176a4052ef774c11a52ff18ad1845102#0"
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
  usage
  exit 1
fi

# Assigning parameters to variables
choice="$1"
ga_id="$2"

# Extract ga_hash and ga_index from ga_id
ga_hash=$(echo "$ga_id" | cut -d '#' -f 1)
ga_index=$(echo "$ga_id" | cut -d '#' -f 2)

# Voting on a governance action
echo "Voting on $ga_id with a $choice."

container_cli conway governance vote create \
    "--$choice" \
    --governance-action-tx-id $ga_hash \
    --governance-action-index $ga_index \
    --cc-hot-verification-key-file ./keys/cc-hot.vkey \
    --out-file ./txs/ga.vote

container_cli conway transaction build --testnet-magic 4 \
    --tx-in "$(container_cli query utxo --address $(cat ./keys/payment.addr) --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]')" \
    --change-address $(cat ./keys/payment.addr) \
    --vote-file ./txs/ga.vote \
    --witness-override 2 \
    --out-file ./txs/vote-tx.raw

container_cli transaction sign \
    --tx-body-file ./txs/vote-tx.raw \
    --signing-key-file ./keys/payment.skey \
    --signing-key-file ./keys/cc-hot.skey \
    --testnet-magic 4 \
    --out-file ./txs/vote-tx.signed

container_cli transaction submit --testnet-magic 4 \
    --tx-file ./txs/vote-tx.signed
