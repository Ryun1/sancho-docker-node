#!/bin/sh

# Define directories
keys_dir="./keys"
txs_dir="./txs/stake"

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

# Registering your stake key
echo "Registering your stake key."

container_cli conway stake-address registration-certificate \
 --stake-verification-key-file $keys_dir/stake.vkey \
 --key-reg-deposit-amt "$(container_cli conway query gov-state | jq -r .currentPParams.keyDesposit)" \ \
 --out-file $txs_dir/stake-registration.cert

echo "Building transaction"

container_cli conway transaction build \
 --witness-override 2 \
 --tx-in $(container_cli conway query utxo --address $(cat $keys_dir/payment.addr) --out-file  /dev/stdout | jq -r 'keys[1]') \
 --change-address $(cat $keys_dir/payment.addr) \
 --certificate-file $txs_dir/stake-registration.cert \
 --out-file $txs_dir/stake-registration-tx.unsigned

echo "Signing transaction"

container_cli conway transaction sign \
 --tx-body-file $txs_dir/stake-registration-tx.unsigned \
 --signing-key-file $keys_dir/payment.skey \
 --signing-key-file $keys_dir/stake.skey \
 --out-file $txs_dir/stake-registration-tx.signed

echo "Submitting transaction"

container_cli conway transaction submit \
 --tx-file $txs_dir/stake-registration-tx.signed