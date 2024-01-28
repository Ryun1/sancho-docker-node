#!/bin/sh

# Dumping ledger state
echo "Dumping whole ledger state."

# Set alias for convenience
alias sancho-cli="docker exec -ti sancho-node cardano-cli"

sancho-cli conway query ledger-state --testnet-magic 4 > ./dumps/ledger-state.json