#!/bin/sh

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

hot_cred_file="./keys/cc-hot.vkey"

container_cli conway governance committee create-hot-key-authorization-certificate \
  --cold-verification-key-file ./keys/cc-cold.vkey \
  --hot-key-file $hot_cred_file \
  --out-file ./txs/cc-auth-hot.cert \

# --hot-script-file $hot_cred_file \

container_cli conway transaction build \
  --testnet-magic 4 \
  --witness-override 2 \
  --tx-in $(container_cli conway query utxo --address $(cat ./keys/payment.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[0]') \
  --change-address $(cat ./keys/payment.addr) \
  --certificate-file ./txs/cc-auth-hot.cert \
  --out-file ./txs/cc-auth-hot-tx.raw

container_cli conway transaction sign \
  --tx-body-file ./txs/cc-auth-hot-tx.raw \
  --signing-key-file ./keys/payment.skey \
  --signing-key-file ./keys/cc-cold.skey \
  --testnet-magic 4 \
  --out-file ./txs/cc-auth-hot-tx.signed

container_cli conway transaction submit \
  --testnet-magic 4 \
  --tx-file ./txs/cc-auth-hot-tx.signed

