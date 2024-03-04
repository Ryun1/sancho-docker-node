#!/bin/sh

# Generate hot cc keys
echo "Generating new consitutional committee hot key."

# Set alias for convenience
alias container-cli="docker exec -ti sancho-node cardano-cli"

# Generate CC hot keys
container-cli conway governance committee key-gen-hot \
 --verification-key-file keys/cc-hot.vkey \
 --signing-key-file keys/cc-hot.skey \

# Generate CC hot key hash
container-cli conway governance committee key-hash \
 --verification-key-file keys/cc-hot.vkey > keys/cc-hot-key-hash.hash
