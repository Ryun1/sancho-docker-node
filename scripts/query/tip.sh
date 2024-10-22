#!/bin/sh

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

# Query the tip of the blockchain as observed by the node
container_cli conway query tip \
  --testnet-magic 4