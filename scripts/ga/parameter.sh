#!/bin/sh

# ~~~~~~~~~~~~ CHANGE THIS ~~~~~~~~~~~~
prev_ga_hash=""
prev_ga_index="0"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# Building, signing and submitting an parameter change governance action
echo "Creating and submitting parameter change governace action."

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

container_cli conway governance action create-protocol-parameters-update \
  --testnet \
  --governance-action-deposit $(container_cli conway query gov-state --testnet-magic 4 | jq -r '.currentPParams.govActionDeposit') \
  --deposit-return-stake-verification-key-file ./keys/stake.vkey \
  --anchor-url  https://buy-ryan-an-island.com \
  --anchor-data-hash 0000000000000000000000000000000000000000000000000000000000000000 \
  --key-reg-deposit-amt 420420420 \
  --prev-governance-action-tx-id "$prev_ga_hash" \
  --prev-governance-action-index "$prev_ga_index" \
  --out-file ./txs/parameter.action

container_cli conway transaction build \
 --testnet-magic 4 \
 --tx-in "$(container_cli query utxo --address "$(cat ./keys/payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[1]')" \
 --change-address "$(cat ./keys/payment.addr)" \
 --proposal-file ./txs/parameter.action \
 --out-file ./txs/parameter.action.raw

container_cli conway transaction sign \
 --tx-body-file ./txs/parameter.action.raw \
 --signing-key-file ./keys/payment.skey \
 --testnet-magic 4 \
 --out-file ./txs/parameter.action.signed

container_cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./txs/parameter.action.signed

