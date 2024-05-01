#!/bin/sh

# Registering your stake key
echo "Registering your stake key."

# Set alias for convenience
alias container-cli="docker exec -ti sancho-node cardano-cli"

container-cli conway stake-address registration-certificate \
 --stake-verification-key-file ./keys/stake.vkey \
 --key-reg-deposit-amt 2000000 \
 --out-file ./txs/stake-registration.cert

container-cli conway transaction build \
 --testnet-magic 4 \
 --witness-override 2 \
 --tx-in $(container-cli query utxo --address $(cat ./keys/payment.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[0]') \
 --change-address $(cat ./keys/payment.addr) \
 --certificate-file ./txs/stake-registration.cert \
 --out-file ./txs/stake-registration-tx.raw

container-cli transaction sign \
 --tx-body-file ./txs/stake-registration-tx.raw \
 --signing-key-file ./keys/payment.skey \
 --signing-key-file ./keys/stake.skey \
 --testnet-magic 4 \
 --out-file ./txs/stake-registration-tx.signed

container-cli transaction submit \
 --testnet-magic 4 \
 --tx-file ./txs/stake-registration-tx.signed