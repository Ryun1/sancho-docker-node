#!/bin/sh

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

# Query DReps from ledger state
echo "Dumping DReps from ledger state."

container_cli conway query drep-state \
  --testnet-magic 4 \
  --all-dreps > ./dumps/dreps-info.json

container_cli conway query drep-stake-distribution \
  --testnet-magic 4 \
  --all-dreps > ./dumps/dreps-power.json

# Dumping ledger state
echo "Dumping governance ledger state."

container_cli conway query gov-state \
  --testnet-magic 4 > ./dumps/gov-state.json

# Dumping ledger state
echo "Dumping whole ledger state."

container_cli conway query ledger-state \
  --testnet-magic 4 > ./dumps/ledger-state.json

# Dumping proposals stored in ledger state
echo "Dumping governance actions in ledger state."

container_cli conway query gov-state \
  --testnet-magic 4 | jq -r '.proposals' > ./dumps/governance-actions.json

# Dumping out CC state
echo "Dumping constitutional committee state."

container_cli conway query committee-state \
  --testnet-magic 4 > ./dumps/committee.json

# Dumping out parameters state
echo "Dumping protocol parameters state."

container_cli conway query protocol-parameters \
  --testnet-magic 4 > ./dumps/params.json