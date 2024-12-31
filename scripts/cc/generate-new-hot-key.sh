#!/bin/sh

# Define directories
keys_dir="./keys"

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

# Generate hot CC keys
echo "Generating a new constitutional committee hot key (replacing the existing one)."

# Generate CC hot keys
container_cli conway governance committee key-gen-hot \
  --verification-key-file "$keys_dir/cc-hot.vkey" \
  --signing-key-file "$keys_dir/cc-hot.skey"

# Generate CC hot key hash
container_cli conway governance committee key-hash \
  --verification-key-file "$keys_dir/cc-hot.vkey" > "$keys_dir/cc-hot-key-hash.hash"