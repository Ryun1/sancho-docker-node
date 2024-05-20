#!/bin/sh

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

orchestrator_key_path="./keys/cc-manager/orchestrator"
orchestrator_script_path="./keys/cc-manager/orchestrator/nft"
orchestrator_tx_path="./txs/orchestrator"
nft_mint_key_path="./keys/nft-mint-keys"

echo "\nBuilding transaction to mint hot and cold NFTs and send them to the orchestrator address"

echo " "
echo "Minting hot and cold NFTs and sending to orchestrator address."
echo "Orchestraor address: $(cat $orchestrator_key_path/orchestrator.addr)"
echo "Cold script policy: $(cat $orchestrator_script_path/native-cold-script.pol)"
echo "Hot script policy: $(cat $orchestrator_script_path/native-hot-script.pol)"
echo "Cold minting key hash: $(cat $nft_mint_key_path/cold.hash)"
echo "Hot minting key hash: $(cat $nft_mint_key_path/hot.hash)"
echo " "

read -p "Are you happy with this info (yes/no): " continue

if [ "$continue" = "yes" ]; then
  continue
else
  echo "Aborting script."
  exit 1
fi

# First we create the two NFTs, making sure that we use the correct minting keys as determined by the scripts

echo "\nBuidling transacion"

container_cli conway transaction build \
 --testnet-magic 4 \
 --tx-in $(container_cli query utxo --address $(cat $orchestrator_key_path/orchestrator.addr) --output-json --testnet-magic 4 | jq -r 'keys[0]') \
 --mint "1 $(cat $orchestrator_script_path/native-cold-script.pol)+ 1 $(cat $orchestrator_script_path/native-hot-script.pol)" \
 --tx-out $(cat $orchestrator_key_path/orchestrator.addr)+10000000+"1 $(cat $orchestrator_script_path/native-cold-script.pol)" \
 --tx-out $(cat $orchestrator_key_path/orchestrator.addr)+10000000+"1 $(cat $orchestrator_script_path/native-hot-script.pol)" \
 --change-address $(cat $orchestrator_key_path/orchestrator.addr) \
 --mint-script-file $orchestrator_script_path/native-cold-script.script \
 --mint-script-file $orchestrator_script_path/native-hot-script.script \
 --required-signer-hash "$(cat "${nft_mint_key_path}/cold.hash")" \
 --required-signer-hash "$(cat "${nft_mint_key_path}/hot.hash")" \
 --out-file $orchestrator_tx_path/mint-nfts.raw

# Sign transaction

echo "\nSigning transacion"

container_cli transaction sign \
 --testnet-magic 4 \
 --signing-key-file $orchestrator_key_path/orchestrator.skey \
 --signing-key-file  $nft_mint_key_path/cold.skey \
 --signing-key-file  $nft_mint_key_path/hot.skey \
 --tx-body-file $orchestrator_tx_path/mint-nfts.raw \
 --out-file $orchestrator_tx_path/mint-nfts.signed

# Submit transaction

echo "\nSubmitting transacion"

echo " "
echo "Orchestraor address: $(cat $orchestrator_key_path/orchestrator.addr)"
echo "Cold script policy: $(cat $orchestrator_script_path/native-cold-script.pol)"
echo "Hot script policy: $(cat $orchestrator_script_path/native-hot-script.pol)"
echo "Cold minting key hash: $(cat $nft_mint_key_path/cold.hash)"
echo "Hot minting key hash: $(cat $nft_mint_key_path/hot.hash)"
echo " "
read -p "Are you sure want to submit this transaction? (yes/no): " answer

if [ "$answer" = "yes" ]; then
  container_cli transaction submit \
   --testnet-magic 4 \
   --tx-file $orchestrator_tx_path/mint-nfts.signed
else
  echo "Transaction submission cancelled."
  exit 1
fi