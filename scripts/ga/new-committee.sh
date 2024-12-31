#!/bin/sh

# ~~~~~~~~~~~~ CHANGE THIS ~~~~~~~~~~~~
PREV_GA_TX_HASH=""
PREV_GA_INDEX="0"

NEW_committee_ANCHOR_URL="ipfs://new-committee.txt"
NEW_committee_ANCHOR_HASH="ab901c3aeeca631ee5c70147a558fbf191a4af245d8ca001e845d8569d7c38f9"

NEW_committee_SCRIPT_HASH="fa24fb305126805cf2164c161d852a0e7330cf988f1fe558cf7d4a64"

METADATA_URL="https://raw.githubusercontent.com/Ryun1/metadata/refs/heads/main/new-const-2"
METADATA_HASH="01318fd6815453f35a4daac80cbbe3bf46c35dc070eb7dc817f26dfee5042eb8"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Define directories
keys_dir="./keys"
txs_dir="./txs/ga"

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

# Building, signing and submitting an new-committee change governance action
echo "Creating and submitting new-committee governance action."

container_cli conway governance action create\
  --testnet \
  --governance-action-deposit $(container_cli conway query gov-state --testnet-magic 4 | jq -r '.currentPParams.govActionDeposit') \
  --deposit-return-stake-verification-key-file ./$keys_dir/stake.vkey \
  --anchor-url "$METADATA_URL" \
  --anchor-data-hash "$METADATA_HASH" \
  --out-file ./$txs_dir/new-committee.action

  # --prev-governance-action-tx-id "$PREV_GA_TX_HASH" \
  # --prev-governance-action-index "$PREV_GA_INDEX" \

container_cli conway transaction build \
 --testnet-magic 4 \
 --tx-in "$(container_cli conway query utxo --address "$(cat ./$keys_dir/payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]')" \
 --tx-in "$(container_cli conway query utxo --address "$(cat ./$keys_dir/payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[1]')" \
 --tx-in-collateral "$(container_cli conway query utxo --address "$(cat ./$keys_dir/payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[1]')" \
 --proposal-file ./$txs_dir/new-committee.action \
 --change-address "$(cat ./$keys_dir/payment.addr)" \
 --out-file ./$txs_dir/new-committee-action-tx.unsigned

container_cli conway transaction sign \
 --tx-body-file ./$txs_dir/new-committee-action-tx.unsigned \
 --signing-key-file ./$keys_dir/payment.skey \
 --testnet-magic 4 \
 --out-file ./$txs_dir/new-committee-action-tx.signed

container_cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./$txs_dir/new-committee-action-tx.signed
