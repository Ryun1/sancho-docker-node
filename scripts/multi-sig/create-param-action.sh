#!/bin/sh

# ~~~~~~~~~~~~ CHANGE THIS ~~~~~~~~~~~~
METADATA_URL="https://buy-ryan-an-island.com"
METADATA_HASH="0000000000000000000000000000000000000000000000000000000000000000"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Define directories
keys_dir="./keys"
txs_dir="./txs/ga"

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

echo "\nPull the latest guardrails script."
curl --silent -J -L https://book.world.dev.cardano.org/environments/mainnet/guardrails-script.plutus -o ./$txs_dir/guardrails-script.plutus

echo "\nGet the guardrails script hash from the genesis file."
SCRIPT_HASH=$(container_cli hash script --script-file ./$txs_dir/guardrails-script.plutus)
echo "Script hash: $SCRIPT_HASH"

# Building, signing and submitting an parameter update governance action
echo "Creating and submitting protocol param update governance action, using the multi-sig's ada."

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

container_cli conway governance action create-protocol-parameters-update \
  --testnet \
  --governance-action-deposit $(container_cli conway query gov-state --testnet-magic 4 | jq -r '.currentPParams.govActionDeposit') \
  --deposit-return-stake-verification-key-file ./$keys_dir/stake.vkey \
  --anchor-url "$METADATA_URL" \
  --anchor-data-hash "$METADATA_HASH" \
  --constitution-script-hash "$SCRIPT_HASH" \
  --key-reg-deposit-amt 3000000 \
  --out-file ./$txs_dir/multi-sig/parameter.action

container_cli conway transaction build \
 --testnet-magic 4 \
 --tx-in "$(container_cli conway query utxo --address "$(cat ./$keys_dir/multi-sig/script.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]')" \
 --tx-in-script-file ./$keys_dir/multi-sig/script.json \
 --tx-in "$(container_cli conway query utxo --address "$(cat ./$keys_dir/payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]')" \
 --tx-in-collateral "$(container_cli conway query utxo --address "$(cat ./$keys_dir/payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]')" \
 --change-address "$(cat ./$keys_dir/payment.addr)" \
 --proposal-file ./$txs_dir/multi-sig/parameter.action \
 --proposal-script-file ./$txs_dir/guardrails-script.plutus \
 --proposal-redeemer-value {} \
 --required-signer-hash "$(cat ./$keys_dir/multi-sig/1.keyhash)" \
 --required-signer-hash "$(cat ./$keys_dir/multi-sig/2.keyhash)" \
 --required-signer-hash "$(cat ./$keys_dir/multi-sig/3.keyhash)" \
 --out-file ./$txs_dir/multi-sig/parameter-action-tx.unsigned

# Create multisig witnesses
container_cli conway transaction witness \
  --testnet-magic 4 \
  --tx-body-file ./$txs_dir/multi-sig/parameter-action-tx.unsigned \
  --signing-key-file ./$keys_dir/multi-sig/1.skey \
  --out-file ./$keys_dir/multi-sig/parameter-action-1.witness

container_cli conway transaction witness \
  --testnet-magic 4 \
  --tx-body-file ./$txs_dir/multi-sig/parameter-action-tx.unsigned \
  --signing-key-file ./$keys_dir/multi-sig/2.skey \
  --out-file ./$keys_dir/multi-sig/parameter-action-2.witness

container_cli conway transaction witness \
  --testnet-magic 4 \
  --tx-body-file ./$txs_dir/multi-sig/parameter-action-tx.unsigned \
  --signing-key-file ./$keys_dir/multi-sig/3.skey \
  --out-file ./$keys_dir/multi-sig/parameter-action-3.witness

# Create witness
container_cli conway transaction witness \
  --testnet-magic 4 \
  --tx-body-file ./$txs_dir/multi-sig/parameter-action-tx.unsigned \
  --signing-key-file ./$keys_dir/payment.skey \
  --out-file ./$keys_dir/multi-sig/payment.witness

# Assemble Transaction
container_cli transaction assemble \
  --tx-body-file ./$txs_dir/multi-sig/parameter-action-tx.unsigned \
  --witness-file ./$keys_dir/multi-sig/payment.witness \
  --witness-file ./$keys_dir/multi-sig/parameter-action-1.witness \
  --witness-file ./$keys_dir/multi-sig/parameter-action-2.witness \
  --witness-file ./$keys_dir/multi-sig/parameter-action-3.witness \
  --out-file ./$txs_dir/multi-sig/parameter-action-tx.signed

# Submit Transaction
container_cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./$txs_dir/multi-sig/parameter-action-tx.signed

