#!/bin/sh

# Building, signing and submitting an info governance action
echo "Creating and submitting info governace action."

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

container_cli conway governance action create-info \
  --testnet \
  --governance-action-deposit $(container_cli conway query gov-state --testnet-magic 4 | jq -r '.currentPParams.govActionDeposit') \
  --deposit-return-stake-verification-key-file ./keys/stake.vkey \
  --anchor-url  https://buy-ryan-an-island.com \
  --anchor-data-hash 0000000000000000000000000000000000000000000000000000000000000000 \
  --out-file ./txs/info.action

container_cli conway transaction build \
 --testnet-magic 4 \
 --tx-in "$(container_cli query utxo --address "$(cat ./keys/payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]')" \
 --change-address "$(cat ./keys/payment.addr)" \
 --proposal-file ./txs/info.action \
 --out-file ./txs/info.action.raw

container_cli conway transaction sign \
 --tx-body-file ./txs/info.action.raw \
 --signing-key-file ./keys/payment.skey \
 --testnet-magic 4 \
 --out-file ./txs/info.action.signed

container_cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./txs/info.action.signed

