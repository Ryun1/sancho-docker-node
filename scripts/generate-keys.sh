#!/bin/sh

# Check if keys already exist
if [ -f "./keys/drep.id" ]; then
    echo "Keys already generated."
    echo "Exiting."
    exit 0
fi

# Generate keys; payment, stake and DRep.
echo "Generating keys; payment, stake and DRep."
echo "from keys, generate payment address, stake address and DRep ID."

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

# Generate payment keys
container_cli address key-gen \
 --verification-key-file keys/payment.vkey \
 --signing-key-file keys/payment.skey

# Generate stake keys
container_cli stake-address key-gen \
 --verification-key-file keys/stake.vkey \
 --signing-key-file keys/stake.skey \

# Generate DRep keys
container_cli conway governance drep key-gen \
 --verification-key-file keys/drep.vkey \
 --signing-key-file keys/drep.skey \

# Generate DRep ID
container_cli conway governance drep id \
 --drep-verification-key-file keys/drep.vkey \
 --out-file keys/drep.id

# Get payment address from keys
container_cli address build \
 --payment-verification-key-file keys/payment.vkey \
 --stake-verification-key-file keys/stake.vkey \
 --out-file keys/payment.addr \
 --testnet-magic 4

 # Derive stake address from stake keys
container_cli stake-address build \
 --stake-verification-key-file keys/stake.vkey \
 --out-file keys/stake.addr \
 --testnet-magic 4
