#!/bin/sh

# ~~~~~~~~~~~~ CHANGE THIS ~~~~~~~~~~~~
spo_id="" # keyhash of the SPO
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Delegating to an SPO
echo "Delegating you to SPO: $spo_id."

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

# TODO