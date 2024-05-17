#!/bin/sh

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

script_file="$1"  # Get the script directory as an argument

# Check if the input ends with .plutus or .script
if [[ "$script_file" != *.plutus && "$script_file" != *.script ]]; then
  echo "Error: The input file must end with .plutus or .script"
  exit 1
fi

policy_id_file=$(echo "$script_file" | sed 's/\.plutus$//' | sed 's/\.script$//')

container_cli transaction policyid \
  --script-file "$script_file" > "${policy_id_file}.pol"