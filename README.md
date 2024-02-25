
# SanchoNet docker node 🤠

**Current version:** node `8.8.1-pre`

## Prerequisites

### Mac Prerequisites

1. xcode tools.

```zsh
xcode-select --install
```

2. Rosetta.
```zsh
softwareupdate --install-rosetta
```

### Windows Prerequisites

WSL

https://learn.microsoft.com/en-us/windows/wsl/install

### Visual Studio Code

So we can more easily navigate directories.
- https://code.visualstudio.com/

### `Docker`

Install docker desktop.
- https://docs.docker.com/engine/install/

If you are using Apple silicon make sure you have Rosetta enabled via Docker desktop settings.

## Setup Guide

1. Clone this repository.

You may want to make a nice place for this.
```zsh
git clone https://github.com/Ryun1/sancho-docker-node.git
```
3. Open the `sancho-docker-node` folder from inside of Visual Studio Code.

4. Open a terminal inside of VSCode and then add execute file provisions to the scripts.

Windows users will have to run this first.
```bash
wsl
```

Fix file permissions.
```zsh
chmod +x ./start-docker.sh ./stop-docker.sh ./query-sancho.sh ./scripts/*
```

5. Follow the [Usage section](#usage).

## Basic Usage
- Make sure you have docker desktop open and running.
- I have written a few useful bash scripts that you can use.

### Start Node

This script:
- pulls the latest SanchoNet node configs
- pulls the Cardano node docker image
- builds and runs the Cardano node image
- pushes the Node logs to the terminal

```bash
./start-docker.sh
```

If you want to stop the logs (but the node is still running) you can press `control + c`.

#### Check Node is running

In a separate terminal to your running node, you can check its sync progress via this.

```bash
./query-sancho.sh
```

### Stop Node

This script will stop your Cardano node.

```bash
./stop-docker.sh
```

## Doing Stuff

Now you have a node, you can actually do stuff ✨

### Set yourself up

1. Generate yourself some keys, addresses and a DRep ID.

```bash
./scripts/generate-keys.sh
```

2. Get yourself some tAda, so you can make transactions.

Open your new address from [./keys/payment.addr](./keys/payment.addr).

Go to the [SanchoNet faucet](https://sancho.network/faucet) and request some tAda sent to your new address.

### Run Scripts

Check out the [scripts folder](./scripts/) and see what you'd like to do.

I will give an example of what you could do.

Make sure you have a node running for these.

#### Become a DRep, delegate to self and vote.

1. Register as a DRep.

```bash
./scripts/drep-register.sh
```

2. Register your stake key (needed before delegating).

```bash
./scripts/stake-key-register.sh
```

3. Delegate your tAda's voting rights to yourself.

```bash
./scripts/drep-delegate.sh
```

4. Vote on a random Governance Action.

```bash
./scripts/drep-vote.sh
```