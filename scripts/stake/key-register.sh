#!/bin/sh

# Define directories
keys_dir="./keys"
txs_dir="./txs/stake"

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

# Registering your stake key
echo "Registering your stake key."

container_cli conway stake-address registration-certificate \
 --stake-verification-key-file ./$keys_dir/stake.vkey \
 --key-reg-deposit-amt 2000000 \
 --out-file ./$txs_dir/stake-registration.cert

echo "Building transaction"

container_cli conway transaction build \
 --testnet-magic 4 \
 --witness-override 2 \
 --tx-in $(container_cli conway query utxo --address $(cat ./$keys_dir/payment.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[1]') \
 --change-address $(cat ./$keys_dir/payment.addr) \
 --certificate-file ./$txs_dir/stake-registration.cert \
 --out-file ./$txs_dir/stake-registration-tx.unsigned

echo "Signing transaction"

container_cli conway transaction sign \
 --tx-body-file ./$txs_dir/stake-registration-tx.unsigned \
 --signing-key-file ./$keys_dir/payment.skey \
 --signing-key-file ./$keys_dir/stake.skey \
 --testnet-magic 4 \
 --out-file ./$txs_dir/stake-registration-tx.signed

echo "Submitting transaction"

container_cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./$txs_dir/stake-registration-tx.signed