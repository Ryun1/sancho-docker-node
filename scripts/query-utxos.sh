#!/bin/sh

# Set alias for convenience
alias container-cli="docker exec -ti sancho-node cardano-cli"

# Query the UTxOs controlled by the payment address
container-cli query utxo \
    --address $(cat ./keys/payment.addr) \
    --testnet-magic 4 --out-file  /dev/stdout