#!/bin/sh

# Set alias for convenience
alias container-cli="docker exec -ti sancho-node cardano-cli"

# Query the tip of the blockchain as observed by the node
container-cli query tip --testnet-magic 4