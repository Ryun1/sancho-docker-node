#!/bin/sh

# ~~~~~~~~~~~~ CHANGE THIS ~~~~~~~~~~~~
choice="yes" # "yes", "no" or "abstain"
ga_hash="66cbbf693a8549d0abb1b5219f1127f8176a4052ef774c11a52ff18ad1845102"
ga_index="0"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Voting on a governance action
echo "Voting on $ga_hash#$ga_index with a $choice."

# Set alias for convenience
alias container-cli="docker exec -ti sancho-node cardano-cli"

container-cli conway governance vote create \
    "--$choice" \
    --governance-action-tx-id $ga_hash \
    --governance-action-index $ga_index \
    --drep-verification-key-file ./keys/drep.vkey \
    --out-file ./txs/ga.vote

container-cli conway transaction build --testnet-magic 4 \
    --tx-in "$(container-cli query utxo --address $(cat ./keys/payment.addr) --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]')" \
    --change-address $(cat ./keys/payment.addr) \
    --vote-file ./txs/ga.vote \
    --witness-override 2 \
    --out-file ./txs/vote-tx.raw

container-cli transaction sign \
    --tx-body-file ./txs/vote-tx.raw \
    --signing-key-file ./keys/drep.skey \
    --signing-key-file ./keys/payment.skey \
    --testnet-magic 4 \
    --out-file ./txs/vote-tx.signed

container-cli transaction submit --testnet-magic 4 --tx-file ./txs/vote-tx.signed
