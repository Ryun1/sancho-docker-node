
# SanchoNet docker node 🤠

## Prerequisites

### Visual Studio Code

So we can more easily navigate directories.
- https://code.visualstudio.com/

### `Docker`

Install docker desktop.
- https://docs.docker.com/engine/install/

If you are using Apple silicon make sure you have Rosetta enabled via Docker desktop settings.

### `Docker Compose`

Install docker-compose.
- https://docs.docker.com/compose/install/

## Mac Setup Guide

1. Install [Homebrew](https://brew.sh/) if you don't have it.

Install.
```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Add homebrew to zprofile file (needed for Apple silicon).
```zsh
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
```

2. Install `wget`.

```zsh
brew install wget
```

3. Clone this repository.

You may want to make a nice place for this.
```zsh
git clone https://github.com/Ryun1/sancho-docker-node.git
```

4. Open the `sancho-docker-node` folder from inside of VsCode.

5. Add execute file provisions to the scripts
```zsh
chmod +x ./start-docker.sh ./stop-docker.sh ./query-sancho.sh ./scripts/*
```

6. Follow the [Usage section](#usage).

## Windows Setup Guide

https://learn.microsoft.com/en-us/windows/wsl/install


## Usage
- Make sure you have docker desktop open and running.
- I have written a few useful bash scripts that you can use.

### Start Node

This script is 

```bash
./start-docker.sh
```

#### Check Node is running

```bash
./query-sancho.sh
```

### Stop Node
```bash
./stop-docker.sh
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

