#!/bin/sh

echo "Authorizing your CC hot key."

# Set alias for convenience
alias sancho-cli="docker exec -ti sancho-node cardano-cli"

# Generate CC cold keys
sancho-cli conway governance committee create-hot-key-authorization-certificate \
 --cold-verification-key-file keys/cc-cold.vkey \
 --hot-key-file keys/cc-hot.vkey \
 --out-file ./txs/cc-auth-hot.cert \

sancho-cli conway transaction build \
 --testnet-magic 4 \
 --witness-override 2 \
 --tx-in $(sancho-cli query utxo --address $(cat ./keys/payment.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[0]') \
 --change-address $(cat ./keys/payment.addr) \
 --certificate-file ./txs/cc-auth-hot.cert \
 --out-file ./txs/cc-auth-hot-tx.raw

sancho-cli conway transaction sign \
 --tx-body-file ./txs/cc-auth-hot-tx.raw \
 --signing-key-file ./keys/payment.skey \
 --signing-key-file ./keys/cc-cold.skey \
 --testnet-magic 4 \
 --out-file ./txs/cc-auth-hot-tx.signed

sancho-cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./txs/cc-auth-hot-tx.signed

