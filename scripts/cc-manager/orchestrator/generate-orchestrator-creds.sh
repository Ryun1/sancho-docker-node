#!/bin/sh

orchestrator_key_path="./keys/cc-manager/orchestrator"

# Check if keys already exist
if [ -f "$orchestrator_key_path/orchestrator.skey" ]; then
    echo "Keys already generated."
    echo "Exiting."
    exit 0
fi

# Generate keys; payment, stake.
echo "Generating keys; payment, stake for orchestrator."
echo "from keys, generate payment address."

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

# Generate payment keys
container_cli address key-gen \
 --verification-key-file $orchestrator_key_path/orchestrator.vkey \
 --signing-key-file $orchestrator_key_path/orchestrator.skey

# Generate stake keys
container_cli stake-address key-gen \
 --verification-key-file $orchestrator_key_path/stake.vkey \
 --signing-key-file $orchestrator_key_path/stake.skey \

# Get payment address from keys
container_cli address build \
 --payment-verification-key-file $orchestrator_key_path/orchestrator.vkey \
 --stake-verification-key-file $orchestrator_key_path/stake.vkey \
 --out-file $orchestrator_key_path/orchestrator.addr \
 --testnet-magic 4