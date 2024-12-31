#!/bin/sh

# Registering your stake key
echo "Registering your stake key."

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

container_cli conway stake-address registration-certificate \
 --stake-verification-key-file ./keys/stake.vkey \
 --key-reg-deposit-amt 2000000 \
 --out-file ./txs/stake-registration.cert

container_cli conway transaction build \
 --testnet-magic 4 \
 --witness-override 2 \
 --tx-in $(container_cli conway query utxo --address $(cat ./keys/payment.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[1]') \
 --change-address $(cat ./keys/payment.addr) \
 --certificate-file ./txs/stake-registration.cert \
 --out-file ./txs/stake-registration-tx.unsigned

container_cli conway transaction sign \
 --tx-body-file ./txs/stake-registration-tx.unsigned \
 --signing-key-file ./keys/payment.skey \
 --signing-key-file ./keys/stake.skey \
 --testnet-magic 4 \
 --out-file ./txs/stake-registration-tx.signed

container_cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./txs/stake-registration-tx.signed