#!/bin/sh

# Dumping ledger state
echo "Dumping governance ledger state."

# Set alias for convenience
alias sancho-cli="docker exec -ti sancho-node cardano-cli"

sancho-cli conway query gov-state --testnet-magic 4 > ./dumps/localGovState.json