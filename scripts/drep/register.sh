#!/bin/sh

# Registering you as a drep
echo "Registering you as a DRep."

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

container_cli conway governance drep registration-certificate \
 --drep-key-hash "$(cat ./keys/drep.id)" \
 --key-reg-deposit-amt "$(container_cli conway query gov-state --testnet-magic 4 | jq -r .currentPParams.dRepDeposit)" \
 --out-file ./txs/drep-register.cert

container_cli conway transaction build \
 --testnet-magic 4 \
 --witness-override 2 \
 --tx-in $(container_cli query utxo --address $(cat ./keys/payment.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[0]') \
 --change-address $(cat ./keys/payment.addr) \
 --certificate-file ./txs/drep-register.cert \
 --out-file ./txs/drep-reg-tx.raw

container_cli conway transaction sign \
 --tx-body-file ./txs/drep-reg-tx.raw \
 --signing-key-file ./keys/payment.skey \
 --signing-key-file ./keys/drep.skey \
 --testnet-magic 4 \
 --out-file ./txs/drep-reg-tx.signed

container_cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./txs/drep-reg-tx.signed
