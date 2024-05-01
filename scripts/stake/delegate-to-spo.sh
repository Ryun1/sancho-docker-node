#!/bin/sh

# ~~~~~~~~~~~~ CHANGE THIS ~~~~~~~~~~~~
spo_id="pool104flte3y29dprxcntacsuyznhduvlaza38gvp8yyhy2vvmfenxa" # keyhash of the SPO
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Delegating to an SPO
echo "Delegating you to SPO: $spo_id."

# Set alias for convenience
alias container-cli="docker exec -ti sancho-node cardano-cli"

container-cli conway stake-address stake-delegation-certificate \
 --stake-verification-key-file ./keys/stake.vkey \
 --stake-pool-id "$spo_id" \
 --out-file ./txs/stake-deleg-key-hash.cert

container-cli conway transaction build \
 --testnet-magic 4 \
 --witness-override 2 \
 --tx-in $(container-cli query utxo --address $(cat ./keys/payment.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[0]') \
 --change-address $(cat ./keys/payment.addr) \
 --certificate-file ./txs/stake-deleg-key-hash.cert \
 --out-file ./txs/stake-deleg-tx.raw

container-cli conway transaction sign \
 --tx-body-file ./txs/stake-deleg-tx.raw \
 --signing-key-file ./keys/payment.skey \
 --signing-key-file ./keys/stake.skey \
 --testnet-magic 4 \
 --out-file ./txs/stake-deleg-tx.signed

container-cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./txs/stake-deleg-tx.signed