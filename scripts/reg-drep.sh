#!/bin/sh

# Registering you as a drep
echo "Registering you as a DRep."

# Set alias for convenience
alias sancho-cli="docker exec -ti sancho-node cardano-cli"

sancho-cli conway governance drep registration-certificate \
 --drep-verification-key-file ./keys/drep.vkey \
 --key-reg-deposit-amt $(sancho-cli conway query gov-state --testnet-magic 4 | jq -r .enactState.curPParams.dRepDeposit) \
 --out-file ./txs/drep-register.cert

sancho-cli conway governance drep registration-certificate \
 --drep-verification-key "$(cat ./keys/drep.vkey | jq -r .cborHex | cut -c 5-)" \
 --key-reg-deposit-amt $(sancho-cli conway query gov-state --testnet-magic 4 | jq -r .enactState.curPParams.dRepDeposit) \
 --out-file ./txs/drep-register.cert

sancho-cli conway governance drep registration-certificate \
 --drep-key-hash $(cat ./keys/drep.id) \
 --key-reg-deposit-amt $(sancho-cli conway query gov-state --testnet-magic 4 | jq -r .enactState.curPParams.dRepDeposit) \
 --out-file ./txs/drep-register.cert

sancho-cli conway transaction build \
 --testnet-magic 4 \
 --witness-override 2 \
 --tx-in $(sancho-cli query utxo --address $(cat ./keys/payment.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[0]') \
 --change-address $(cat ./keys/payment.addr) \
 --certificate-file ./txs/drep-register.cert \
 --out-file ./txs/drep-reg-tx.raw

sancho-cli conway transaction sign \
 --tx-body-file ./txs/drep-reg-tx.raw \
 --signing-key-file ./keys/payment.skey \
 --signing-key-file ./keys/drep.skey \
 --testnet-magic 4 \
 --out-file ./txs/drep-reg-tx.signed

sancho-cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./txs/drep-reg-tx.signed
