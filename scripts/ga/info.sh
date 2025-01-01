#!/bin/sh

# ~~~~~~~~~~~~ CHANGE THIS ~~~~~~~~~~~~

METADATA_URL="https://raw.githubusercontent.com/IntersectMBO/governance-actions/refs/heads/main/mainnet/2024-11-19-infohf/metadata.jsonld"
METADATA_HASH="93106d082a93e94df5aff74f678438bae3a647dac63465fbfcde6a3058f41a1e"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Define directories
keys_dir="./keys"
txs_dir="./txs/ga"

# Get the script's directory
script_dir=$(dirname "$0")

# Get the container name from the get-container script
container_name="$("$script_dir/../helper/get-container.sh")"

if [ -z "$container_name" ]; then
  echo "Failed to determine a running container."
  exit 1
fi

echo "Using running container: $container_name"

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti $container_name cardano-cli "$@"
}

# Building, signing and submitting an info governance action
echo "Creating and submitting info governance action."

container_cli conway governance action create-info \
  --testnet \
  --governance-action-deposit $(container_cli conway query gov-state --testnet-magic 4 | jq -r '.currentPParams.govActionDeposit') \
  --deposit-return-stake-verification-key-file ./$keys_dir/stake.vkey \
  --anchor-url $METADATA_URL \
  --anchor-data-hash $METADATA_HASH \
  --out-file ./$txs_dir/info.action

echo "Building transaction"

container_cli conway transaction build \
 --testnet-magic 4 \
 --tx-in "$(container_cli conway query utxo --address "$(cat ./$keys_dir/payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]')" \
 --change-address "$(cat ./$keys_dir/payment.addr)" \
 --proposal-file ./$txs_dir/info.action \
 --out-file ./$txs_dir/info-action-tx.unsigned

echo "Signing transaction"

container_cli conway transaction sign \
 --tx-body-file ./$txs_dir/info-action-tx.unsigned \
 --signing-key-file ./$keys_dir/payment.skey \
 --testnet-magic 4 \
 --out-file ./$txs_dir/info-action-tx.signed

echo "Submitting transaction"

container_cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./$txs_dir/info-action-tx.signed
