#!/bin/sh

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

# Query the stake pools
container_cli conway query stake-pools \
  --testnet-magic 4