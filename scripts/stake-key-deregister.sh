#!/bin/sh

# Unregistering your stake key
echo "Deregistering your stake key."

# Set alias for convenience
alias sancho-cli="docker exec -ti sancho-node cardano-cli"

sancho-cli conway stake-address deregistration-certificate \
 --stake-verification-key-file ./keys/stake.vkey \
 --key-reg-deposit-amt 2000000 \
 --out-file ./txs/stake-deregistration.cert

sancho-cli conway transaction build \
 --testnet-magic 4 \
 --witness-override 2 \
 --tx-in $(sancho-cli query utxo --address $(cat ./keys/payment.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[0]') \
 --change-address $(cat ./keys/payment.addr) \
 --certificate-file ./txs/stake-deregistration.cert \
 --out-file ./txs/stake-deregistration-tx.raw

sancho-cli transaction sign \
 --tx-body-file ./txs/stake-deregistration-tx.raw \
 --signing-key-file ./keys/payment.skey \
 --signing-key-file ./keys/stake.skey \
 --testnet-magic 4 \
 --out-file ./txs/stake-deregistration-tx.signed

sancho-cli transaction submit \
 --testnet-magic 4 \
 --tx-file ./txs/stake-deregistration-tx.signed