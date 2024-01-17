FROM ghcr.io/intersectmbo/cardano-node:8.7.2
ENV CARDANO_NODE_SOCKET_PATH=/ipc/node.socket
ENTRYPOINT ["/usr/local/bin/cardano-node", "run", "+RTS", "-N", "-A16m", "-qg", "-qb", "-RTS", "--topology", "/config/topology.json", "--database-path", "/data/db", "--socket-path", "/ipc/node.socket", "--host-addr", "0.0.0.0", "--port", "3001", "--config", "/config/config.json" ]
