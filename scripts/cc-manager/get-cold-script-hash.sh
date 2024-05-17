#!/bin/sh

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

container_cli transaction policyid \
  --script-file ./scripts/cc-manager/coldCredentialScript.plutus
