#!/bin/sh

echo "Resigning your CC cold key."

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

# Generate CC cold keys
container_cli conway governance committee create-cold-key-resignation-certificate \
 --cold-verification-key-file keys/cc-cold.vkey \
 --out-file ./txs/cc-resign-cold.cert \

container_cli conway transaction build \
 --testnet-magic 4 \
 --witness-override 2 \
 --tx-in $(container_cli query utxo --address $(cat ./keys/payment.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[0]') \
 --change-address $(cat ./keys/payment.addr) \
 --certificate-file ./txs/cc-resign-cold.cert \
 --out-file ./txs/cc-resign-cold-tx.raw

container_cli conway transaction sign \
 --tx-body-file ./txs/cc-resign-cold-tx.raw \
 --signing-key-file ./keys/payment.skey \
 --signing-key-file ./keys/cc-cold.skey \
 --testnet-magic 4 \
 --out-file ./txs/cc-resign-cold-tx.signed

container_cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./txs/cc-resign-cold-tx.signed

