#!/bin/sh

# ~~~~~~~~~~~~ CHANGE THIS ~~~~~~~~~~~~
prev_ga_hash=""
prev_ga_index="0"

METADATA_URL="https://raw.githubusercontent.com/Ryun1/metadata/refs/heads/main/test-ga-2.jsonld"
METADATA_HASH="a8dfd5d606424edf56bba038f227777fd1fb7651baa5007fee32e62430a289e8"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Building, signing and submitting an parameter change governance action
echo "Creating and submitting parameter change governace action."

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
  --governance-action-deposit 100000000 \
  --deposit-return-stake-verification-key-file ./keys/stake.vkey \
  --anchor-url "$METADATA_URL" \
  --anchor-data-hash "$METADATA_HASH" \
  --constitution-script-hash "$SCRIPT_HASH" \
  --cost-model-file ./txs/test-plutusv3-params.json \
  --out-file ./txs/parameter.action

  # --prev-governance-action-tx-id "$prev_ga_hash" \
  # --prev-governance-action-index "$prev_ga_index" \

echo "Building the transaction."

container_cli conway transaction build \
 --testnet-magic 4 \
 --tx-in "df1a6a8ebeb369825180eb6203d912c9e8d94b603b175ad25c6190835647f690#0" \
 --tx-in "dd21e6f14ad292b26f6282676aa0199156da711ddef8982ec3417b6023324a05#1" \
 --tx-in-collateral "dd21e6f14ad292b26f6282676aa0199156da711ddef8982ec3417b6023324a05#1" \
 --proposal-file ./txs/parameter.action \
 --proposal-script-file ./txs/guardrails-script.plutus \
 --proposal-redeemer-value {} \
 --change-address "$(cat ./keys/payment.addr)" \
 --out-file ./txs/parameter.action.raw

# container_cli conway transaction sign \
#  --tx-body-file ./txs/parameter.action.raw \
#  --signing-key-file ./keys/payment.skey \
#  --testnet-magic 4 \
#  --out-file ./txs/parameter.action.signed

# container_cli conway transaction submit \
#  --testnet-magic 4 \
#  --tx-file ./txs/parameter.action.signed

