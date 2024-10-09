#!/bin/sh

# Registering you as a drep
echo "Registering you as a native script multisig DRep."

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

# Iterate through the template and add payment, stake and DRep keys to it
# cp ./scripts/drep/multi-sig-template.json ./txs/multisig-drep.json

# # Capture the keyHash values and ensure no newline characters
# newHash1=$(container_cli address key-hash --payment-verification-key-file "./keys/payment.vkey" | tr -d '\n')
# newHash2=$(container_cli address key-hash --payment-verification-key-file "./keys/payment.vkey" | tr -d '\n')
# newHash3=$(container_cli address key-hash --payment-verification-key-file "./keys/payment.vkey" | tr -d '\n')

# # Use the captured values in jq
# updated_json=$(jq --arg newHash1 "$newHash1" \
#                   --arg newHash2 "$newHash2" \
#                   --arg newHash3 "$newHash3" \
#                   '.scripts[0].keyHash = $newHash1 | 
#                    .scripts[1].keyHash = $newHash2 | 
#                    .scripts[2].keyHash = $newHash3' "./txs/multisig-drep.json")

# # Write the updated JSON to file
# echo "$updated_json" > "./txs/multisig-drep.json"

container_cli hash script \
  --script-file ./txs/multisig-drep.json \
  --out-file ./txs/multisig-drep.id

container_cli conway governance drep registration-certificate \
 --drep-script-hash "$(cat ./txs/multisig-drep.id)" \
 --key-reg-deposit-amt "$(container_cli conway query gov-state --testnet-magic 4 | jq -r .currentPParams.dRepDeposit)" \
 --out-file ./txs/drep-multisig-register.cert

container_cli conway transaction build \
 --testnet-magic 4 \
 --witness-override 2 \
 --tx-in $(container_cli query utxo --address $(cat ./keys/payment.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[0]') \
 --change-address $(cat ./keys/payment.addr) \
 --certificate-file ./txs/drep-multisig-register.cert \
 --certificate-script-file ./txs/multisig-drep.json \
 --out-file ./txs/reg-drep-multisig-register.unsigned

container_cli conway transaction witness \
  --testnet-magic 4 \
  --tx-body-file ./txs/reg-drep-multisig-register.unsigned \
  --signing-key-file ./keys/payment.skey \
  --out-file ./txs/reg-drep-multisig-register.witness

container_cli transaction assemble \
  --tx-body-file ./txs/reg-drep-multisig-register.unsigned \
  --witness-file ./txs/reg-drep-multisig-register.witness \
  --out-file ./txs/reg-drep-multisig-register.signed

container_cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./txs/reg-drep-multisig-register.signed
