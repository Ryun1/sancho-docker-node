
alias container-cli="docker exec -ti sancho-node cardano-cli"

# container-cli query utxo --testnet-magic 4 \
#     --address $(container-cli address build \
#     --testnet-magic 4 \
#     --payment-verification-key-file ./keys/payment.vkey)

container-cli query utxo --address $(cat ./keys/payment.addr) --testnet-magic 4 --out-file  /dev/stdout