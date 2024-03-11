#!/bin/sh

# ~~~~~~~~~~~~ CHANGE THIS ~~~~~~~~~~~~
drep_id="" # keyhash of the drep
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Delegating to an DRep
echo "Delegating you to DRep: $drep_id."

# Set alias for convenience
alias container-cli="docker exec -ti sancho-node cardano-cli"

# TODO