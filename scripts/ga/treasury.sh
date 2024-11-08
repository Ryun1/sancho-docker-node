#!/bin/sh

# ~~~~~~~~~~~~ CHANGE THIS ~~~~~~~~~~~~
LOVELACE_AMOUNT="100000000"

PREV_GA_TX_HASH="0f19207eb4fdb7c538549588ad0a17c577df797ba5d9f1b51658501485ca30b8"
PREV_GA_INDEX="0"

METADATA_URL="https://raw.githubusercontent.com/Ryun1/metadata/refs/heads/main/cip108/treasury-withdrawal.jsonld"
METADATA_HASH="633e6f25fea857662d1542921f1fa2cab5f90a9e4cb51bdae8946f823e403ea8"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Building, signing and submitting an treasury governance action
echo "Creating and submitting treasury withdrawal governace action."

echo "\nPull the latest guardrails script."
curl --silent -J -L https://book.world.dev.cardano.org/environments/mainnet/guardrails-script.plutus -o ./txs/guardrails-script.plutus

# echo "\nGet the guardrails script hash from the genesis file."
SCRIPT_HASH=$(jq -r ".constitution.script" "./node/config/conway-genesis.json")
echo "Script hash: $SCRIPT_HASH"

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

container_cli conway governance action create-treasury-withdrawal \
  --testnet \
  --governance-action-deposit $(container_cli conway query gov-state --testnet-magic 4 | jq -r '.currentPParams.govActionDeposit') \
  --deposit-return-stake-verification-key-file ./keys/stake.vkey \
  --anchor-url "$METADATA_URL" \
  --anchor-data-hash "$METADATA_HASH" \
  --check-anchor-data \
  --funds-receiving-stake-verification-key-file ./keys/stake.vkey \
  --transfer $LOVELACE_AMOUNT \
  --constitution-script-hash $SCRIPT_HASH \
  --out-file ./txs/treasury.action

echo "Building the transaction."

container_cli conway transaction build \
 --testnet-magic 4 \
 --tx-in "$(container_cli conway query utxo --address "$(cat ./keys/payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]')" \
 --tx-in "$(container_cli conway query utxo --address "$(cat ./keys/payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[1]')" \
 --tx-in "$(container_cli conway query utxo --address "$(cat ./keys/payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[3]')" \
 --tx-in-collateral "$(container_cli conway query utxo --address "$(cat ./keys/payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[1]')" \
 --proposal-file ./txs/treasury.action \
 --proposal-script-file ./txs/guardrails-script.plutus \
 --proposal-redeemer-value {} \
 --change-address "$(cat ./keys/payment.addr)" \
 --out-file ./txs/treasury-action-tx.unsigned

container_cli conway transaction sign \
 --tx-body-file ./txs/treasury-action-tx.unsigned \
 --signing-key-file ./keys/payment.skey \
 --testnet-magic 4 \
 --out-file ./txs/treasury-action-tx.signed

container_cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./txs/treasury-action-tx.signed

