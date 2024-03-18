#!/bin/sh

# Set directory locations
node_dir="./node"
config_dir="$node_dir/config"
db_dir="$node_dir/db"
ipc_dir="$node_dir/ipc"

# Base URL for node config files
config_base_url="https://book.world.dev.cardano.org/environments/sanchonet/"

# Pull the latest node config files, put them inside the node/config directory

# Create db directory if it doesn't exist
if [ ! -d "$db_dir" ]; then
  mkdir -p "$db_dir"
fi

# Remove existing ipc directory if it exists and create a new one
if [ -d "$ipc_dir" ]; then
  rm -rf "$ipc_dir"
fi
mkdir -p "$ipc_dir"

# Create config directory if it doesn't exist
if [ ! -d "$config_dir" ]; then
  mkdir -p "$config_dir"
fi

# List of JSON files to download
config_files=(
    "config.json"
    "topology.json"
    "byron-genesis.json"
    "shelley-genesis.json"
    "alonzo-genesis.json"
    "conway-genesis.json"
)

# Change directory to the JSON directory and download files
cd "$config_dir" || exit
for file in "${config_files[@]}"; do
    curl --silent -O -J -L "${config_base_url}${file}"
done

# Start the Docker container
docker-compose up -d --build

# Follow the logs to the terminal
docker logs sancho-node --follow
