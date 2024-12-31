#!/bin/sh

# Predefined list of container names
containers=("sancho-node" "another-node" "yet-another-node")

# Function to check if a container is running
is_container_running() {
  docker ps --filter "name=$1" --filter "status=running" | grep -q "$1"
}

# Find running containers from the predefined list
running_containers=()
for container in "${containers[@]}"; do
  if is_container_running "$container"; then
    running_containers+=("$container")
  fi
done

# Determine which container to use
if [ ${#running_containers[@]} -eq 1 ]; then
  container_name=${running_containers[0]}
  echo "Using running container: $container_name"
elif [ ${#running_containers[@]} -gt 1 ]; then
  echo "Multiple running containers found. Please select one:"
  select container_name in "${running_containers[@]}"; do
    if [ -n "$container_name" ]; then
      break
    fi
  done
else
  echo "No running containers found from the predefined list."
  exit 1
fi

# Registering you as a drep
echo "Registering you as a DRep."

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti "$container_name" cardano-cli "$@"
}

# Registering you as a drep
echo "Registering you as a DRep."

container_cli conway governance drep registration-certificate \
 --drep-key-hash "$(cat $keys_dir/drep.id)" \
 --key-reg-deposit-amt "$(container_cli conway query gov-state --testnet-magic 4 | jq -r .currentPParams.dRepDeposit)" \
 --out-file $txs_dir/drep-register.cert

echo "Building transaction"

container_cli conway transaction build \
 --testnet-magic 4 \
 --witness-override 2 \
 --tx-in $(container_cli conway query utxo --address $(cat ./keys/payment.addr) --testnet-magic 4 --out-file  /dev/stdout | jq -r 'keys[0]') \
 --change-address $(cat ./keys/payment.addr) \
 --certificate-file ./txs/drep-register.cert \
 --out-file ./txs/drep-reg-tx.raw

container_cli conway transaction sign \
 --tx-body-file $txs_dir/drep-reg-tx.unsigned \
 --signing-key-file $keys_dir/payment.skey \
 --signing-key-file $keys_dir/drep.skey \
 --testnet-magic 4 \
 --out-file $txs_dir/drep-reg-tx.signed

echo "Submitting transaction"

container_cli conway transaction submit \
 --testnet-magic 4 \
 --tx-file ./txs/drep-reg-tx.signed
