#!/bin/bash

# Set alias for convenience
container-cli() {
    docker exec -ti sancho-node cardano-cli "$@"
}

########################################################################
# Modify the INDEXNO variable depending on the maximum index number
# per transaction ID that you want to submit.
# ex: INDEXNO=49 will give you 50 governance actions, including index 0.

INDEXNO=30

#############################
# Do not modify whats below #
#############################
AMOUNT=1000000000
building_gov_action() {   
    sleep 0.5
    echo "------------------------------------------"
    echo "              Creating Action"
    echo "------------------------------------------"
    sleep 0.5
    
    #create the action file directory   
    mkdir ./txs/hornan/action-create 2>/dev/null
    rm ./txs/hornan/my_outputs.txt 2>/dev/null
     
    #create the vote files
    while true; do
            if [ "$INDEXNO" != "0" ]; then
                    container-cli conway governance action create-treasury-withdrawal \
  		    --testnet \
  		    --governance-action-deposit 1000000000 \
  		    --deposit-return-stake-verification-key-file ./keys/stake.vkey \
  		    --anchor-url https://hornan7.github.io/proposal.txt \
  		    --anchor-data-hash 460059c9aded5a476378db48cafa45f5c0cc733b389262364207ccf5ebae1590 \
  		    --funds-receiving-stake-verification-key-file ./keys/stake.vkey \
  		    --transfer ${AMOUNT} \
  		    --out-file ./txs/hornan/action-create/action${INDEXNO}.action
                echo " --proposal-file ./txs/hornan/action-create/action${INDEXNO}.action" >> ./txs/hornan/action-create/txvar.txt
                echo -ne "\rPreparing action number ${INDEXNO} "
                sleep 0.1
		AMOUNT=$((AMOUNT-1000000))
                INDEXNO=$((INDEXNO-1))
            else
	    	if [ "$INDEXNO" -eq "0" ]; then
                    container-cli conway governance action create-treasury-withdrawal \
                    --testnet \
                    --governance-action-deposit 1000000000 \
                    --deposit-return-stake-verification-key-file ./keys/stake.vkey \
                    --anchor-url https://hornan7.github.io/proposal.txt \
                    --anchor-data-hash 460059c9aded5a476378db48cafa45f5c0cc733b389262364207ccf5ebae1590 \
                    --funds-receiving-stake-verification-key-file ./keys/stake.vkey \
                    --transfer ${AMOUNT} \
                    --out-file ./txs/hornan/action-create/action${INDEXNO}.action
                echo " --proposal-file ./txs/hornan/action-create/action${INDEXNO}.action" >> ./txs/hornan/action-create/txvar.txt
                echo -ne "\rPreparing action number ${INDEXNO} "

                    sleep 0.5
		fi      
                break  
            fi
    done
}

building_gov_action           
echo "------------------------------------------"
echo "           Building Transaction"
echo "------------------------------------------"
sleep 0.2

        # Build the Transaction
        container-cli conway transaction build \
        --testnet-magic 4 \
        --tx-in "$(container-cli query utxo --address $(cat ./keys/payment.addr) --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]')" \
        --change-address $(cat ./keys/payment.addr) \
        $(cat ./txs/hornan/action-create/txvar.txt) \
        --witness-override 2 \
        --out-file ./txs/action-tx.raw
        
# Remove the action index options file        
rm -rf ./txs/hornan/action-create
  
echo "           Signing Transaction"
echo "------------------------------------------"
sleep 0.2

        # Sign the transaction
        container-cli transaction sign --tx-body-file ./txs/action-tx.raw \
        --signing-key-file ./keys/stake.skey \
        --signing-key-file ./keys/payment.skey \
        --testnet-magic 4 \
        --out-file ./txs/action-tx.signed

echo "      Submiting Transaction On-Chain"
echo "------------------------------------------"
sleep 0.2

        # Submit the Transaction
        container-cli transaction submit \
        --testnet-magic 4 \
        --tx-file ./txs/action-tx.signed > ./txs/hornan/my_outputs.txt 2>&1

 	# Add the governance action to a sharable list
  	if [ "$(cat ./txs/hornan/my_outputs.txt)" == "Transaction successfully submitted." ]; then
   	  container-cli conway transaction txid \
   	  --tx-file ./txs/action-tx.signed >> ./txs/actionsID.txt
      	  echo "Governance action ID as been added to ./txs/actionsID.txt file."
	  echo "Share ./txs/actionsID.txt with the others when you're done."
   	  echo "Governance action submition complete"
      	else
          echo "Couldn't add the governance action ID to actionID.txt file because of a transaction error."
	  echo "Please tell Mike that he F%/?ed up."
    	  echo "Governance action submition failed, see ./txs/hornan/my_outputs.txt file for error logs."
	fi
unset INDEXNO
unset AMOUNT