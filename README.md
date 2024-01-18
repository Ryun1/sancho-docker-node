
# SanchoNet docker node 🤠

---

## Requirements

### Visual Studio Code
https://code.visualstudio.com/

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
$ chmod +x ./start-docker.sh ./stop-docker.sh ./query-sancho.sh ./set-alias.sh ./scripts/*
```

### Start
```bash
$ ./start-docker.sh
```

### Query
```bash
$ ./query-sancho.sh
```

### Stop
```bash
$ ./stop-docker.sh
```

## Doing Stuff

Now you have a node, you can actually do stuff on the network.

### Set yourself up

#### Generate yourself some keys, addresses and a DRep ID.

⚠️ THIS WILL WIPE YOUR OLD KEYS, SO PLEASE ONLY DO IT ONCE ⚠️

```bash
$ ./scripts/generate-keys.sh
```

#### Get yourself some tAda

Go to the faucet and request some tAda sent to your new address.

Open your keys

