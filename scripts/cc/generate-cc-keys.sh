#!/bin/sh

# Check if cc keys already exist
if [ -f "./keys/cc-cold.vkey" ]; then
    echo "Consitutional committee keys already generated."
    echo "Exiting."
    exit 0
fi

# Generate cc keys
echo "Generating consitutional committee hot and cold keys."

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

# Generate CC cold keys
container_cli conway governance committee key-gen-cold \
 --verification-key-file ./keys/cc-cold.vkey \
 --signing-key-file ./keys/cc-cold.skey \

# Generate CC hot keys
container_cli conway governance committee key-gen-hot \
 --verification-key-file ./keys/cc-hot.vkey \
 --signing-key-file ./keys/cc-hot.skey \

# Generate CC cold key hash, just so we have it
container_cli conway governance committee key-hash \
 --verification-key-file ./keys/cc-cold.vkey > keys/cc-cold-key-hash.hash

# Generate CC cold key hash, just so we have it
container_cli conway governance committee key-hash \
 --verification-key-file ./keys/cc-hot.vkey > keys/cc-hot-key-hash.hash
