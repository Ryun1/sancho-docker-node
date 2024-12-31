#!/bin/sh

# ~~~~~~~~~~~~ CHANGE THIS ~~~~~~~~~~~~
drep_id="3f3d4a84b800b34eb84c6151a955cdd823a0b99e3b886c725b8769e5" # keyhash of the drep
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Define directories
keys_dir="./keys"
txs_dir="./txs/stake"

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

# Delegating to an DRep
echo "Delegating you to DRep: $drep_id."

container_cli conway stake-address vote-delegation-certificate \
 --stake-verification-key-file ./$keys_dir/stake.vkey \
 --drep-key-hash "$drep_id" \
 --out-file ./$txs_dir/vote-deleg-key-hash.cert

container_cli conway transaction build \
 --testnet-magic 4 \
 --witness-override 2 \
 --tx-in $(container_cli conway query utxo --address $(cat ./$keys_dir/payment.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[0]') \
 --change-address $(cat ./$keys_dir/payment.addr) \
 --certificate-file ./$txs_dir/vote-deleg-key-hash.cert \
 --out-file ./$txs_dir/vote-deleg-tx.unsigned

container_cli conway transaction sign \
 --tx-body-file ./$txs_dir/vote-deleg-tx.unsigned \
 --signing-key-file ./$keys_dir/payment.skey \
 --signing-key-file ./$keys_dir/stake.skey \
 --testnet-magic 4 \
 --out-file ./$txs_dir/vote-deleg-tx.signed

container_cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./$txs_dir/vote-deleg-tx.signed