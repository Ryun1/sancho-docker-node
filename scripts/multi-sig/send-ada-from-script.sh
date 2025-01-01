#!/bin/sh

# ~~~~~~~~~~~~ CHANGE THIS ~~~~~~~~~~~~
LOVELACE_AMOUNT=1000000
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Define directories
keys_dir="./keys"
txs_dir="./txs/ga"

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

# Send ada to the multisig payment script
echo "Sending $LOVELACE_AMOUNT lovelace to the payment address from the script."

echo "Building transaction"

container_cli conway transaction build \
 --testnet-magic 4 \
 --tx-in $(container_cli conway query utxo --address $(cat ./$keys_dir/multi-sig/script.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[0]') \
 --tx-in-script-file ./$keys_dir/multi-sig/script.json \
 --tx-out $(cat ./$keys_dir/payment.addr)+$LOVELACE_AMOUNT \
 --change-address $(cat ./$keys_dir/multi-sig/script.addr) \
 --required-signer-hash "$(cat ./$keys_dir/multi-sig/1.keyhash)" \
 --required-signer-hash "$(cat ./$keys_dir/multi-sig/3.keyhash)" \
 --out-file ./$txs_dir/multi-sig/send-ada-from-script.unsigned

# Create witnesses

# Key 1
container_cli conway transaction witness \
  --testnet-magic 4 \
  --tx-body-file ./$txs_dir/multi-sig/send-ada-from-script.unsigned \
  --signing-key-file ./$keys_dir/multi-sig/1.skey \
  --out-file ./$txs_dir/multi-sig/send-ada-from-script-1.witness

# Key 2
# container_cli conway transaction witness \
#   --testnet-magic 4 \
#   --tx-body-file ./$txs_dir/multi-sig/send-ada-from-script.unsigned \
#   --signing-key-file ./$keys_dir/multi-sig/2.skey \
#   --out-file ./$txs_dir/multi-sig/send-ada-from-script-2.witness

# Key 3
container_cli conway transaction witness \
  --testnet-magic 4 \
  --tx-body-file ./$txs_dir/multi-sig/send-ada-from-script.unsigned \
  --signing-key-file ./$keys_dir/multi-sig/3.skey \
  --out-file ./$txs_dir/multi-sig/send-ada-from-script-3.witness

# Assemble transaction
container_cli transaction assemble \
  --tx-body-file ./$txs_dir/multi-sig/send-ada-from-script.unsigned \
  --witness-file ./$txs_dir/multi-sig/send-ada-from-script-1.witness \
  --witness-file ./$txs_dir/multi-sig/send-ada-from-script-3.witness \
  --out-file ./$txs_dir/multi-sig/send-ada-from-script.signed

# Submit transaction
echo "Submitting transaction"

container_cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./$txs_dir/multi-sig/send-ada-from-script.signed
