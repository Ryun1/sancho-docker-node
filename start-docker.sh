#!/bin/sh

# Pull the latest Node config files
cd ./node-config
curl --silent -O -J -L https://book.world.dev.cardano.org/environments/sanchonet/config.json
curl --silent -O -J -L https://book.world.dev.cardano.org/environments/sanchonet/topology.json
curl --silent -O -J -L https://book.world.dev.cardano.org/environments/sanchonet/byron-genesis.json
curl --silent -O -J -L https://book.world.dev.cardano.org/environments/sanchonet/shelley-genesis.json
curl --silent -O -J -L https://book.world.dev.cardano.org/environments/sanchonet/alonzo-genesis.json
curl --silent -O -J -L https://book.world.dev.cardano.org/environments/sanchonet/conway-genesis.json
cd ..

# Remove any existing socket
rm -rf ./node-ipc/node.socket

# Start the Docker container
docker-compose up -d --build

# Follow the logs to the terminal
docker logs sancho-node --follow
