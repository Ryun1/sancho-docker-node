#!/bin/sh

# Define directories
keys_dir="./keys"
txs_dir="./txs/drep"

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

# Retiring you as a drep
echo "Retiring you as a DRep."

container_cli conway governance drep retirement-certificate \
 --drep-key-hash $(cat $keys_dir/drep.id) \
 --deposit-amt $(container_cli conway query gov-state --testnet-magic 4 | jq -r .currentPParams.dRepDeposit) \
 --out-file $txs_dir/drep-retire.cert

echo "Building transaction"

container_cli conway transaction build \
 --testnet-magic 4 \
 --witness-override 2 \
 --tx-in $(container_cli conway query utxo --address $(cat $keys_dir/payment.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[0]') \
 --change-address $(cat $keys_dir/payment.addr) \
 --certificate-file $txs_dir/drep-retire.cert \
 --out-file $txs_dir/drep-retire-tx.unsigned

echo "Signing transaction"

container_cli conway transaction sign \
 --tx-body-file $txs_dir/drep-retire-tx.unsigned \
 --signing-key-file $keys_dir/payment.skey \
 --signing-key-file $keys_dir/drep.skey \
 --testnet-magic 4 \
 --out-file $txs_dir/drep-retire-tx.signed

echo "Submitting transaction"

container_cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file $txs_dir/drep-retire-tx.signed
