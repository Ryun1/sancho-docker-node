#!/bin/sh

# Dumping ledger state
echo "Dumping whole ledger state."

# Set alias for convenience
alias container-cli="docker exec -ti sancho-node cardano-cli"

container-cli conway query ledger-state --testnet-magic 4 > ./dumps/ledger-state.json