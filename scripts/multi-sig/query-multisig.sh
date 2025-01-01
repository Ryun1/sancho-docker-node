#!/bin/sh

# Define directories
keys_dir="./keys"

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

echo "Querying UTXOs for your multisig script address: $(cat $keys_dir/multi-sig/script.addr)"

# Query the UTxOs controlled by multisig script address
container_cli conway query utxo \
  --address "$(cat $keys_dir/multi-sig/script.addr)" \
  --out-file  /dev/stdout