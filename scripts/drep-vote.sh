#!/bin/sh

ga_hash="0ce78e5d0b2ff4079aa28a5d500e49b1f78ad35807656fae6a76aa11b4e3fcb4"
ga_index="0"

# Registering your stake key
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
