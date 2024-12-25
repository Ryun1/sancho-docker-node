#!/bin/sh

# ~~~~~~~~~~~~ CHANGE THIS ~~~~~~~~~~~~
PREV_GA_TX_HASH="0f19207eb4fdb7c538549588ad0a17c577df797ba5d9f1b51658501485ca30b8"
PREV_GA_INDEX="0"

METADATA_URL="https://raw.githubusercontent.com/IntersectMBO/governance-actions/refs/heads/main/mainnet/2024-10-21-ppu/metadata.jsonld"
METADATA_HASH="3e6b1083a637a740d5b84bb6edf1a5119b81440b31ea84907311b6543ebd39eb"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Building, signing and submitting an parameter change governance action
echo "Creating and submitting parameter change governance action."

echo "\nPull the latest guardrails script."
curl --silent -J -L https://book.world.dev.cardano.org/environments/mainnet/guardrails-script.plutus -o ./txs/guardrails-script.plutus

# echo "\nGet the guardrails script hash from the genesis file."
SCRIPT_HASH=$(jq -r ".constitution.script" "./node/config/conway-genesis.json")
echo "Script hash: $SCRIPT_HASH"

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

container_cli conway governance action create-protocol-parameters-update \
  --testnet \
  --governance-action-deposit $(container_cli conway query gov-state --testnet-magic 4 | jq -r '.currentPParams.govActionDeposit') \
  --deposit-return-stake-verification-key-file ./keys/stake.vkey \
  --anchor-url "$METADATA_URL" \
  --anchor-data-hash "$METADATA_HASH" \
  --constitution-script-hash $SCRIPT_HASH \
  --cost-model-file ./txs/test-plutusv3-params.json \
  --prev-governance-action-tx-id "$PREV_GA_TX_HASH" \
  --prev-governance-action-index "$PREV_GA_INDEX" \
  --out-file ./txs/parameter.action

echo "Building the transaction."

container_cli conway transaction build \
 --testnet-magic 4 \
 --tx-in "$(container_cli conway query utxo --address "$(cat ./keys/payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]')" \
 --tx-in "$(container_cli conway query utxo --address "$(cat ./keys/payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[1]')" \
 --tx-in "$(container_cli conway query utxo --address "$(cat ./keys/payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[3]')" \
 --tx-in-collateral "$(container_cli conway query utxo --address "$(cat ./keys/payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[1]')" \
 --proposal-file ./txs/parameter.action \
 --proposal-script-file ./txs/guardrails-script.plutus \
 --proposal-redeemer-value {} \
 --change-address "$(cat ./keys/payment.addr)" \
 --out-file ./txs/parameter-action-tx.unsigned

container_cli conway transaction sign \
 --tx-body-file ./txs/parameter-action-tx.unsigned \
 --signing-key-file ./keys/payment.skey \
 --testnet-magic 4 \
 --out-file ./txs/parameter-action-tx.signed

container_cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./txs/parameter-action-tx.signed

