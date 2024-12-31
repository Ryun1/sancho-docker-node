#!/bin/sh

# Define directories
keys_dir="./keys"

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

# Check if CC keys already exist
if [ -f "$keys_dir/cc-cold.vkey" ]; then
    echo "Constitutional committee keys already generated."
    echo "Exiting."
    exit 0
fi

# Generate CC keys
echo "Generating constitutional committee hot and cold keys."

# Generate CC cold keys
container_cli conway governance committee key-gen-cold \
  --verification-key-file "$keys_dir/cc-cold.vkey" \
  --signing-key-file "$keys_dir/cc-cold.skey"

# Generate CC hot keys
container_cli conway governance committee key-gen-hot \
  --verification-key-file "$keys_dir/cc-hot.vkey" \
  --signing-key-file "$keys_dir/cc-hot.skey"

# Generate CC cold key hash
container_cli conway governance committee key-hash \
  --verification-key-file "$keys_dir/cc-cold.vkey" > "$keys_dir/cc-cold-key-hash.hash"

# Generate CC hot key hash
container_cli conway governance committee key-hash \
  --verification-key-file "$keys_dir/cc-hot.vkey" > "$keys_dir/cc-hot-key-hash.hash"