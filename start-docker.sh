#!/bin/sh

# Pull the latest Node config files
cd ./node-config
wget https://book.world.dev.cardano.org/environments/sanchonet/config.json
wget https://book.world.dev.cardano.org/environments/sanchonet/topology.json
wget https://book.world.dev.cardano.org/environments/sanchonet/byron-genesis.json
wget https://book.world.dev.cardano.org/environments/sanchonet/shelley-genesis.json
wget https://book.world.dev.cardano.org/environments/sanchonet/alonzo-genesis.json
wget https://book.world.dev.cardano.org/environments/sanchonet/conway-genesis.json
cd ..

# Remove any existing socket
rm -rf ./node-ipc/node.socket

# Start the Docker container
docker-compose up -d --build

# Follow the logs to the terminal
docker logs sancho-node --follow
