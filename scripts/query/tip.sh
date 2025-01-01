#!/bin/sh

# Get the script's directory
script_dir=$(dirname "$0")

# Get the container name from the check-running-containers script
container_name="$("$script_dir/../helper/check-running-containers.sh")"

if [ -z "$container_name" ]; then
  echo "Failed to determine a running container."
  exit 1
fi

echo "Using running container: $container_name"

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti $container_name cardano-cli "$@"
}

# Query the tip of the blockchain as observed by the node
container_cli conway query tip \
  --testnet-magic 4