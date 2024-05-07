#!/bin/sh

# ~~~~~~~~~~~~ CHANGE THIS ~~~~~~~~~~~~
choice="yes" # "yes", "no" or "abstain"
ga_hash="e0ba9c084a61d937b37db627c4b740697e3e0ca8a6cca3ca21bbe313034e774b"
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
