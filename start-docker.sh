#!/bin/sh

# If no node config directory exists, create it
if [ ! -d ./node/config ]; then
  mkdir -p ./node/config
fi

# Pull the latest Node config files, put them inside the node-config directory
cd ./node/config
curl --silent -O -J -L https://book.world.dev.cardano.org/environments/sanchonet/config.json
curl --silent -O -J -L https://book.world.dev.cardano.org/environments/sanchonet/topology.json
curl --silent -O -J -L https://book.world.dev.cardano.org/environments/sanchonet/byron-genesis.json
curl --silent -O -J -L https://book.world.dev.cardano.org/environments/sanchonet/shelley-genesis.json
curl --silent -O -J -L https://book.world.dev.cardano.org/environments/sanchonet/alonzo-genesis.json
curl --silent -O -J -L https://book.world.dev.cardano.org/environments/sanchonet/conway-genesis.json
cd ..
cd ..

# If no node db directory exists, create it
if [ ! -d ./node/db ]; then
  mkdir -p ./node/db
fi

# Remove any existing socket by overwriting it with an empty directory
mkdir -p ./node/config

# Start the Docker container
docker-compose up -d --build

# Follow the logs to the terminal
docker logs sancho-node --follow
