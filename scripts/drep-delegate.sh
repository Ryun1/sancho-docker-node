#!/bin/sh

echo "Delegating your voting rights to your DRep ID."

# Set alias for convenience
alias sancho-cli="docker exec -ti sancho-node cardano-cli"

sancho-cli conway stake-address vote-delegation-certificate \
 --stake-verification-key-file ./keys/stake.vkey \
 --drep-key-hash "$(cat ./keys/drep.id)" \
 --out-file ./txs/vote-deleg-key-hash.cert

sancho-cli conway transaction build \
 --testnet-magic 4 \
 --witness-override 2 \
 --tx-in $(sancho-cli query utxo --address $(cat ./keys/payment.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[0]') \
 --change-address $(cat ./keys/payment.addr) \
 --certificate-file ./txs/vote-deleg-key-hash.cert \
 --out-file ./txs/vote-deleg-tx.raw

sancho-cli conway transaction sign \
 --tx-body-file ./txs/vote-deleg-tx.raw \
 --signing-key-file ./keys/payment.skey \
 --signing-key-file ./keys/stake.skey \
 --testnet-magic 4 \
 --out-file ./txs/vote-deleg-tx.signed

sancho-cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./txs/vote-deleg-tx.signed