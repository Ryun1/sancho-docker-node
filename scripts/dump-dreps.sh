#!/bin/sh

# Query DReps from ledger state
echo "Querying DReps from ledger state."

# Set alias for convenience
alias sancho-cli="docker exec -ti sancho-node cardano-cli"

sancho-cli conway query drep-state \
    --testnet-magic 4 \
    --all-dreps > ./dumps/dreps-info.json

sancho-cli conway query drep-stake-distribution \
    --testnet-magic 4 \
    --all-dreps > ./dumps/dreps-power.json