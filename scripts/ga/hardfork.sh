#!/bin/sh

# ~~~~~~~~~~~~ CHANGE THIS ~~~~~~~~~~~~
PREV_GA_TX_HASH="fd80ab8f65a620da457c18574787c9e5091bc2c71b776cd5edad0a005c37e307"
PREV_GA_INDEX="0"

METADATA_URL="https://raw.githubusercontent.com/IntersectMBO/governance-actions/refs/heads/main/preview/2024-10-30-hf10/metadata.jsonld"
METADATA_HASH="ab901c3aeeca631ee5c70147a558fbf191a4af245d8ca001e845d8569d7c38f9"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Building, signing and submitting an hardfork change governance action
echo "Creating and submitting hardfork governace action."

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

container_cli conway governance action create-hardfork \
  --testnet \
  --governance-action-deposit $(container_cli conway query gov-state --testnet-magic 4 | jq -r '.currentPParams.govActionDeposit') \
  --deposit-return-stake-verification-key-file ./keys/stake.vkey \
  --anchor-url "$METADATA_URL" \
  --anchor-data-hash "$METADATA_HASH" \
  --protocol-major-version 11 \
  --protocol-minor-version 0 \
  --prev-governance-action-tx-id "$PREV_GA_TX_HASH" \
  --prev-governance-action-index "$PREV_GA_INDEX" \
  --out-file ./txs/hardfork.action

echo "Building the transaction."

container_cli conway transaction build \
 --testnet-magic 4 \
 --tx-in "$(container_cli conway query utxo --address "$(cat ./keys/payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]')" \
 --tx-in "$(container_cli conway query utxo --address "$(cat ./keys/payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[1]')" \
 --tx-in "$(container_cli conway query utxo --address "$(cat ./keys/payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[3]')" \
 --tx-in-collateral "$(container_cli conway query utxo --address "$(cat ./keys/payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[1]')" \
 --proposal-file ./txs/hardfork.action \
 --change-address "$(cat ./keys/payment.addr)" \
 --out-file ./txs/hardfork-action-tx.unsigned

container_cli conway transaction sign \
 --tx-body-file ./txs/hardfork-action-tx.unsigned \
 --signing-key-file ./keys/payment.skey \
 --testnet-magic 4 \
 --out-file ./txs/hardfork-action-tx.signed

container_cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./txs/hardfork-action-tx.signed

