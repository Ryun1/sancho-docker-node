#!/bin/sh

# Dumping ledger state
echo "Dumping governance ledger state."

# Set alias for convenience
alias container-cli="docker exec -ti sancho-node cardano-cli"

container-cli conway query gov-state --testnet-magic 4 > ./dumps/gov-state.json