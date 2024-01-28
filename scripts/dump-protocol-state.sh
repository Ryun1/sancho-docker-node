#!/bin/sh

# Dumping ledger state
echo "Dumping protocol state."

# Set alias for convenience
alias sancho-cli="docker exec -ti sancho-node cardano-cli"

sancho-cli conway query protocol-state --testnet-magic 4 > ./dumps/protocol-state.json