#!/bin/sh

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

orchestrator_key_path="./keys/cc-manager/orchestrator"
orchestrator_script_path="./keys/cc-manager/orchestrator/nft"
orchestrator_tx_path="./txs/orchestrator"
nft_mint_key_path="./keys/nft-mint-keys"

# First we create the two NFTs, making sure that we use the correct minting keys as determined by the scripts
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

# Sign transcaction
container_cli transaction sign \
 --testnet-magic 4 \
 --signing-key-file $orchestrator_key_path/orchestrator.skey \
 --signing-key-file  $nft_mint_key_path/cold.skey \
 --signing-key-file  $nft_mint_key_path/hot.skey \
 --tx-body-file $orchestrator_tx_path/mint-nfts.raw \
 --out-file $orchestrator_tx_path/mint-nfts.signed

# container_cli transaction submit \
#  --testnet-magic 4 \
#  --tx-file $orchestrator_tx_path/mint-nfts.signed