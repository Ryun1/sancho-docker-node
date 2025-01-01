#!/bin/sh

# Define directories
keys_dir="./keys"
txs_dir="./txs/cc"

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

# Create vote
container_cli conway governance vote create \
  "--$choice" \
  --governance-action-tx-id "$ga_hash" \
  --governance-action-index "$ga_index" \
  --cc-hot-verification-key-file "$keys_dir/cc-hot.vkey" \
  --out-file "$txs_dir/ga.vote"

# Build transaction
echo "Building transaction"

container_cli conway transaction build \
  --testnet-magic 4 \
  --tx-in "$(container_cli conway query utxo --address $(cat "$keys_dir/payment.addr") --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]')" \
  --change-address "$(cat "$keys_dir/payment.addr")" \
  --vote-file "$txs_dir/ga.vote" \
  --witness-override 2 \
  --out-file "$txs_dir/vote-tx.unsigned"

# Sign transaction
container_cli transaction sign \
  --tx-body-file "$txs_dir/vote-tx.unsigned" \
  --signing-key-file "$keys_dir/payment.skey" \
  --signing-key-file "$keys_dir/cc-hot.skey" \
  --testnet-magic 4 \
  --out-file "$txs_dir/vote-tx.signed"

# Submit transaction
container_cli transaction submit \
  --testnet-magic 4 \
  --tx-file "$txs_dir/vote-tx.signed"