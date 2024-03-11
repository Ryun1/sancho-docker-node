#!/bin/sh

# ~~~~~~~~~~~~ CHANGE THIS ~~~~~~~~~~~~
spo_id="" # keyhash of the SPO
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Delegating to an SPO
echo "Delegating you to SPO: $spo_id."

# Set alias for convenience
alias container-cli="docker exec -ti sancho-node cardano-cli"

# TODO