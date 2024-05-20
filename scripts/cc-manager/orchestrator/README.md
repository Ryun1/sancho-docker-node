
## Orchestrator Flows

1. `./generate-orchestrator-credentials.sh`

Generates payment, stake keys for orchestrator and payment address.
Has a check to not overwrite existing keys.

**in real world:** Orchestrator will already have a set of credentials on their own setup.

2. `./mint-sign-submit-nfts.sh`

Using the cold and hot minting policies to mint one cold and one hot NFT, sending to orchestrator address.
This transaction needs to be signed by the keys included within the minting policy scripts, one for the cold and one for the hot.
⚠️ Important to double check that YOU control the orchestrator address.

**in real world:** Ran by the orchestrator on their own setup, or in conjunction with head of security.

3. `./check-orchestrator-utxos.sh`

This gives an output to console showing the UTxOs controlled by the orchestrator address