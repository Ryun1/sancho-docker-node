# filepath: /Users/ryan/cardano/node/sancho-docker-node/scripts/drep/register.sh
#!/bin/sh

# Define directories
keys_dir="./keys"
txs_dir="./txs/drep"

# Get the script's directory
script_dir=$(dirname "$0")

# Get the container name from the check-running-containers script
container_name=$("$script_dir/../helper/check-running-containers.sh")

if [ -z "$container_name" ]; then
  echo "Failed to determine a running container."
  exit 1
fi

echo "Using running container: $container_name"

# Registering you as a drep
echo "Registering you as a DRep"

container_cli conway governance drep registration-certificate \
 --drep-key-hash "$(cat $keys_dir/drep.id)" \
 --key-reg-deposit-amt "$(container_cli conway query gov-state --testnet-magic 4 | jq -r .currentPParams.dRepDeposit)"