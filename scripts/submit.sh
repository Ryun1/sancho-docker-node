alias container-cli="docker exec -ti sancho-node cardano-cli"

container-cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./txs/tx.signed