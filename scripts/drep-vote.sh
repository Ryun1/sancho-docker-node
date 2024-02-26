#!/bin/sh

ga_hash="d34c2b2899a4b80e52a487067ca8c9b8a909208ca42d6c35f895944de7866d1b"
ga_index="0"

# Voting on a governance action
echo "Voting on $ga_hash"

# Set alias for convenience
alias sancho-cli="docker exec -ti sancho-node cardano-cli"

sancho-cli conway governance vote create \
    --yes \
    --governance-action-tx-id $ga_hash \
    --governance-action-index $ga_index \
    --drep-verification-key-file ./keys/drep.vkey \
    --out-file ./txs/ga.vote

sancho-cli conway transaction build --testnet-magic 4 \
    --tx-in "$(sancho-cli query utxo --address $(cat ./keys/payment.addr) --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]')" \
    --change-address $(cat ./keys/payment.addr) \
    --vote-file ./txs/ga.vote \
    --witness-override 2 \
    --out-file ./txs/vote-tx.raw

sancho-cli transaction sign \
    --tx-body-file ./txs/vote-tx.raw \
    --signing-key-file ./keys/drep.skey \
    --signing-key-file ./keys/payment.skey \
    --testnet-magic 4 \
    --out-file ./txs/vote-tx.signed

sancho-cli transaction submit --testnet-magic 4 --tx-file ./txs/vote-tx.signed
