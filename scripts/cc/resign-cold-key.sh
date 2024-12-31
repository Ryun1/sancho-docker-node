#!/bin/sh

# Define directories
keys_dir="./keys"
txs_dir="./txs/cc"

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

echo "Resigning your CC cold key."

# Generate CC cold key resignation certificate
container_cli conway governance committee create-cold-key-resignation-certificate \
  --cold-verification-key-file "$keys_dir/cc-cold.vkey" \
  --out-file "$txs_dir/resign-cold.cert"

# Build transaction
container_cli conway transaction build \
  --testnet-magic 4 \
  --witness-override 2 \
  --tx-in $(container_cli conway query utxo --address $(cat "$keys_dir/payment.addr") --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]') \
  --change-address $(cat "$keys_dir/payment.addr") \
  --certificate-file "$txs_dir/resign-cold.cert" \
  --out-file "$txs_dir/resign-cold-tx.raw"

# Sign transaction
container_cli conway transaction sign \
  --tx-body-file "$txs_dir/resign-cold-tx.raw" \
  --signing-key-file "$keys_dir/payment.skey" \
  --signing-key-file "$keys_dir/cc-cold.skey" \
  --testnet-magic 4 \
  --out-file "$txs_dir/resign-cold-tx.signed"

# Submit transaction
container_cli conway transaction submit \
  --testnet-magic 4 \
  --tx-file "$txs_dir/resign-cold-tx.signed"