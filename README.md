
# SanchoNet docker node 🤠

---

## Requirements

**Windows**
https://learn.microsoft.com/en-us/windows/wsl/install

### `wget`

**Mac**
```bash
$ brew install wget
```

**Linux**
```bash
$ apt-get install wget
```

### `Docker`
- https://docs.docker.com/engine/install/

### `Docker Compose`
- https://docs.docker.com/compose/install/

## Usage
- Make sure you have docker open and running.

### Correct permissions
```bash
chmod +x ./start.sh ./stop.sh ./query-sancho.sh
```

### Start
```bash
$ ./start.sh
```

### Query
```bash
docker exec -ti sancho-node /usr/local/bin/cardano-cli query tip --testnet-magic 4
```

### Stop
```bash
$ ./stop.sh
```
