#!/bin/sh

depositRefundAmt=$(docker exec -ti sancho-node cardano-cli conway query gov-state --testnet-magic 4 | jq -r .enactState.curPParams.dRepDeposit)

# Retiring you as a drep
echo "Retiring you as a DRep."

# Set alias for convenience
alias sancho-cli="docker exec -ti sancho-node cardano-cli"

sancho-cli conway governance drep retirement-certificate \
 --drep-key-hash $(cat ./keys/drep.id) \
 --deposit-amt $depositRefundAmt \
 --out-file ./txs/drep-retire.cert

sancho-cli conway transaction build \
 --testnet-magic 4 \
 --witness-override 2 \
 --tx-in $(sancho-cli query utxo --address $(cat ./keys/payment.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[0]') \
 --change-address $(cat ./keys/payment.addr) \
 --certificate-file ./txs/drep-retire.cert \
 --out-file ./txs/drep-retire-tx.raw

sancho-cli conway transaction sign \
 --tx-body-file ./txs/drep-retire-tx.raw \
 --signing-key-file ./keys/payment.skey \
 --signing-key-file ./keys/drep.skey \
 --testnet-magic 4 \
 --out-file ./txs/drep-retire-tx.signed

sancho-cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./txs/drep-retire-tx.signed
