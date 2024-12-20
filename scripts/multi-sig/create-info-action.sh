#!/bin/sh

# ~~~~~~~~~~~~ CHANGE THIS ~~~~~~~~~~~~
METADATA_URL="https://buy-ryan-an-island.com"
METADATA_HASH="0000000000000000000000000000000000000000000000000000000000000000"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Building, signing and submitting an info governance action
echo "Creating and submitting info governace action, using the multi-sig's ada."

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

container_cli conway governance action create-info \
  --testnet \
  --governance-action-deposit $(container_cli conway query gov-state --testnet-magic 4 | jq -r '.currentPParams.govActionDeposit') \
  --deposit-return-stake-verification-key-file ./keys/stake.vkey \
  --anchor-url "$METADATA_URL" \
  --anchor-data-hash "$METADATA_HASH" \
  --out-file ./txs/multi-sig/info.action

container_cli conway transaction build \
 --testnet-magic 4 \
 --tx-in "$(container_cli conway query utxo --address "$(cat ./keys/multi-sig/script.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]')" \
 --tx-in-script-file ./keys/multi-sig/script.json \
 --tx-in "$(container_cli conway query utxo --address "$(cat ./keys/payment.addr)" --testnet-magic 4 --out-file /dev/stdout | jq -r 'keys[0]')" \
 --change-address "$(cat ./keys/payment.addr)" \
 --proposal-file ./txs/multi-sig/info.action \
 --required-signer-hash "$(cat ./keys/multi-sig/1.keyhash)" \
 --required-signer-hash "$(cat ./keys/multi-sig/2.keyhash)" \
 --required-signer-hash "$(cat ./keys/multi-sig/3.keyhash)" \
 --out-file ./txs/multi-sig/info-action-tx.unsigned

# Create multisig witnesses
container_cli conway transaction witness \
  --testnet-magic 4 \
  --tx-body-file ./txs/multi-sig/info-action-tx.unsigned \
  --signing-key-file ./keys/multi-sig/1.skey \
  --out-file ./keys/multi-sig/info-action-1.witness

container_cli conway transaction witness \
  --testnet-magic 4 \
  --tx-body-file ./txs/multi-sig/info-action-tx.unsigned \
  --signing-key-file ./keys/multi-sig/2.skey \
  --out-file ./keys/multi-sig/info-action-2.witness

container_cli conway transaction witness \
  --testnet-magic 4 \
  --tx-body-file ./txs/multi-sig/info-action-tx.unsigned \
  --signing-key-file ./keys/multi-sig/3.skey \
  --out-file ./keys/multi-sig/info-action-3.witness

# Create witness
container_cli conway transaction witness \
  --testnet-magic 4 \
  --tx-body-file ./txs/multi-sig/info-action-tx.unsigned \
  --signing-key-file ./keys/payment.skey \
  --out-file ./keys/multi-sig/payment.witness

# Assemble Transaction
container_cli transaction assemble \
  --tx-body-file ./txs/multi-sig/info-action-tx.unsigned \
  --witness-file ./keys/multi-sig/payment.witness \
  --witness-file ./keys/multi-sig/info-action-1.witness \
  --witness-file ./keys/multi-sig/info-action-2.witness \
  --witness-file ./keys/multi-sig/info-action-3.witness \
  --out-file ./txs/multi-sig/info-action-tx.signed

# Submit Transaction
container_cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./txs/multi-sig/info-action-tx.signed

