#!/bin/sh

# ~~~~~~~~~~~~ CHANGE THIS ~~~~~~~~~~~~
PREV_GA_TX_HASH=""
PREV_GA_INDEX="0"

NEW_CONSTITUTION_ANCHOR_URL="https://buy-ryan-an-island.com"
NEW_CONSTITUTION_ANCHOR_HASH="ab901c3aeeca631ee5c70147a558fbf191a4af245d8ca001e845d8569d7c38f9"
NEW_CONSTITUTION_SCRIPT_HASH="fa24fb305126805cf2164c161d852a0e7330cf988f1fe558cf7d4a64"

METADATA_URL="https://raw.githubusercontent.com/Ryun1/metadata/refs/heads/main/new-const.jsonld"
METADATA_HASH="62ad72128cf3dad0bff82e5702113b082a3cca817cfd79b2699cbb95e7144133"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Building, signing and submitting an new-constitution change governance action
echo "Creating and submitting new-constitution governace action."

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

container_cli conway governance action create-constitution \
  --testnet \
  --governance-action-deposit $(container_cli conway query gov-state --testnet-magic 4 | jq -r '.currentPParams.govActionDeposit') \
  --deposit-return-stake-verification-key-file ./keys/stake.vkey \
  --anchor-url "$METADATA_URL" \
  --anchor-data-hash "$METADATA_HASH" \
  --constitution-url "$NEW_CONSTITUTION_ANCHOR_URL" \
  --constitution-hash "$NEW_CONSTITUTION_ANCHOR_HASH" \
  --constitution-script-hash "$NEW_CONSTITUTION_SCRIPT_HASH" \
  --out-file ./txs/new-constitution.action

  # --prev-governance-action-tx-id "$PREV_GA_TX_HASH" \
  # --prev-governance-action-index "$PREV_GA_INDEX" \

echo "Building the transaction."

container_cli conway transaction build \
 --testnet-magic 4 \
 --tx-in "$(container_cli conway query utxo --address "$(cat ./keys/payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]')" \
 --tx-in "$(container_cli conway query utxo --address "$(cat ./keys/payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[1]')" \
 --tx-in-collateral "$(container_cli conway query utxo --address "$(cat ./keys/payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[1]')" \
 --proposal-file ./txs/new-constitution.action \
 --change-address "$(cat ./keys/payment.addr)" \
 --out-file ./txs/new-constitution-action-tx.unsigned

container_cli conway transaction sign \
 --tx-body-file ./txs/new-constitution-action-tx.unsigned \
 --signing-key-file ./keys/payment.skey \
 --testnet-magic 4 \
 --out-file ./txs/new-constitution-action-tx.signed

container_cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./txs/new-constitution-action-tx.signed
