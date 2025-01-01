#!/bin/sh

# Define directories
keys_dir="./keys"
txs_dir="./txs/stake"

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

# Unregistering your stake key
echo "Deregistering your stake key."

container_cli conway stake-address deregistration-certificate \
 --stake-verification-key-file $keys_dir/stake.vkey \
 --key-reg-deposit-amt $(container_cli conway query gov-state --testnet-magic 4 | jq -r .currentPParams.keyDeposit) \
 --out-file ./$txs_dir/stake-deregistration.cert

echo "Building transaction"

container_cli conway transaction build \
 --testnet-magic 4 \
 --witness-override 2 \
 --tx-in $(container_cli conway query utxo --address $(cat $keys_dir/payment.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[0]') \
 --change-address $(cat $keys_dir/payment.addr) \
 --certificate-file ./$txs_dir/stake-deregistration.cert \
 --out-file ./$txs_dir/stake-deregistration-tx.unsigned

container_cli transaction sign \
 --tx-body-file ./$txs_dir/stake-deregistration-tx.unsigned \
 --signing-key-file $keys_dir/payment.skey \
 --signing-key-file $keys_dir/stake.skey \
 --testnet-magic 4 \
 --out-file ./$txs_dir/stake-deregistration-tx.signed

container_cli transaction submit \
 --testnet-magic 4 \
 --tx-file ./$txs_dir/stake-deregistration-tx.signed