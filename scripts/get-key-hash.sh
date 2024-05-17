#!/bin/sh

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

vkey_file="$1"  # Get the .vkey directory as an argument

# Check if the input ends with .vkey
if [[ "$vkey_file" != *.vkey ]]; then
  echo "Error: The input file must end with .vkey"
  exit 1
fi

vkey_hash_file=$(echo "$vkey_file" | sed 's/\.vkey$//')

container_cli address key-hash \
  --payment-verification-key-file "$vkey_file" > "${vkey_hash_file}.hash"