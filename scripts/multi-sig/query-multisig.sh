#!/bin/sh

echo "Creating a multisig payment credential."

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

container_cli address build \
  --testnet-magic 4 \
  --payment-script-file ./txs/multi-payment/multisig-payment-cred.json \
  --out-file ./txs/multi-payment/multisig-payment-script.addr

# Send ada to the multisig payment script
echo "Sending 100K ada to the multisig payment address."

container_cli conway transaction build \
 --testnet-magic 4 \
 --tx-in $(container_cli query utxo --address $(cat ./keys/payment.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[0]') \
 --tx-out $(cat ./txs/multi-payment/multisig-payment-script.addr)+100000000000 \
 --change-address $(cat ./keys/payment.addr) \
 --out-file ./txs/send-ada-to-script.unsigned

container_cli transaction sign \
  --tx-body-file ./txs/send-ada-to-script.unsigned \
  --signing-key-file ./keys/payment.skey \
  --out-file ./txs/send-ada-to-script.signed

container_cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./txs/send-ada-to-script.signed

echo "Building a Info governance action using the ada held by the ."



# something else

# container_cli conway transaction witness \
#   --testnet-magic 4 \
#   --tx-body-file ./txs/reg-drep-multisig-register.unsigned \
#   --signing-key-file ./keys/payment.skey \
#   --out-file ./txs/reg-drep-multisig-register.witness

# container_cli transaction assemble \
#   --tx-body-file ./txs/reg-drep-multisig-register.unsigned \
#   --witness-file ./txs/reg-drep-multisig-register.witness \
#   --out-file ./txs/reg-drep-multisig-register.signed

# container_cli conway transaction submit \
#  --testnet-magic 4 \
#  --tx-file ./txs/reg-drep-multisig-register.signed
