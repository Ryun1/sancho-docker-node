#!/bin/sh

# ~~~~~~~~~~~~ CHANGE THIS ~~~~~~~~~~~~
choice="yes" # "yes", "no" or "abstain"
ga_hash="10749d25c892a6ec20fc9365425dc204c6a2699ce1586bdb0e6802eccd6263f2"
ga_index="0"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Voting on a governance action
echo "Voting on $ga_hash#$ga_index with a $choice."

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

container_cli conway governance vote create \
    "--$choice" \
    --governance-action-tx-id $ga_hash \
    --governance-action-index $ga_index \
    --cc-hot-verification-key-file ./keys/cc-hot.vkey \
    --out-file ./txs/ga.vote

container_cli conway transaction build --testnet-magic 4 \
    --tx-in "$(container_cli query utxo --address $(cat ./keys/payment.addr) --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]')" \
    --change-address $(cat ./keys/payment.addr) \
    --vote-file ./txs/ga.vote \
    --witness-override 2 \
    --out-file ./txs/vote-tx.raw

container_cli transaction sign \
    --tx-body-file ./txs/vote-tx.raw \
    --signing-key-file ./keys/payment.skey \
    --signing-key-file ./keys/cc-hot.skey \
    --testnet-magic 4 \
    --out-file ./txs/vote-tx.signed

container_cli transaction submit --testnet-magic 4 \
    --tx-file ./txs/vote-tx.signed
