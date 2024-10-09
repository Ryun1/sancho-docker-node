#!/bin/sh

# ~~~~~~~~~~~~ CHANGE THIS ~~~~~~~~~~~~
ADA_AMOUNT=100000000000
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

# Send ada to the multisig payment script
echo "Sending $ADA_AMOUNT ada to the multisig payment address."

container_cli conway transaction build \
 --testnet-magic 4 \
 --tx-in $(container_cli query utxo --address $(cat ./keys/payment.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[0]') \
 --tx-out $(cat ./keys/multi-sig/script.addr)+$ADA_AMOUNT \
 --change-address $(cat ./keys/payment.addr) \
 --out-file ./txs/multi-sig/send-ada-to-script.unsigned

container_cli transaction sign \
  --tx-body-file ./txs/multi-sig/send-ada-to-script.unsigned \
  --signing-key-file ./keys/payment.skey \
  --out-file ./txs/multi-sig/send-ada-to-script.signed

container_cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./txs/multi-sig/send-ada-to-script.signed
