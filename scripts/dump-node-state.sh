#!/bin/sh

# Set alias for convenience
alias container-cli="docker exec -ti sancho-node cardano-cli"

# Query DReps from ledger state
echo "Dumping DReps from ledger state."

container-cli conway query drep-state \
    --testnet-magic 4 \
    --all-dreps > ./dumps/dreps-info.json

container-cli conway query drep-stake-distribution \
    --testnet-magic 4 \
    --all-dreps > ./dumps/dreps-power.json

# Dumping ledger state
echo "Dumping governance ledger state."

container-cli conway query gov-state \
    --testnet-magic 4 > ./dumps/gov-state.json

# Dumping ledger state
echo "Dumping whole ledger state."

container-cli conway query ledger-state \
    --testnet-magic 4 > ./dumps/ledger-state.json

# Dumping proposals stored in ledger state
echo "Dumping governance actions in ledger state."

container-cli conway query gov-state \
    --testnet-magic 4 | jq -r '.proposals' > ./dumps/governance-actions.json

# Dumping ledger state
echo "Dumping protocol state."

container-cli conway query protocol-state \
    --testnet-magic 4 > ./dumps/protocol-state.json