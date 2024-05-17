#!/bin/sh

# Function to execute cardano-cli commands inside the container
container_cli() {
  docker exec -ti sancho-node cardano-cli "$@"
}

# Function to create PEM files from signing keys
create_pem() {
  local key_file=$1
  local pem_file=$2
  cat "$key_file" | jq -r ".cborHex" | cut -c 5- | \
    (echo -n "302e020100300506032b657004220420" && cat) | \
    xxd -r -p | base64 | \
    (echo "-----BEGIN PRIVATE KEY-----" && cat) | \
    (cat && echo "-----END PRIVATE KEY-----") > "$pem_file"
}

keys_per_role=1
key_subject="/C=US/ST=x/L=x/O=IntersectMBO/OU=x/CN=x"

# Define CA key file paths
ca_skey="./keys/cc-manager/ca/ca.skey"
ca_vkey="./keys/cc-manager/ca/ca.vkey"
ca_vkey_hash="./keys/cc-manager/ca/ca.keyhash"

# Check if any of the ca key files already exist
if [ -f "$ca_vkey" ] || [ -f "$ca_skey" ]; then
  echo "CA key files already exist. Exiting script to avoid overwriting."
  exit 1
fi

# Create directories if they do not exist
mkdir -p ./keys/cc-manager/ca
mkdir -p ./keys/cc-manager/voter
mkdir -p ./keys/cc-manager/delegation
mkdir -p ./keys/cc-manager/member

# Generate keys + keyhash for CA role
container_cli address key-gen \
  --signing-key-file "$ca_skey" \
  --verification-key-file "$ca_vkey"

container_cli address key-hash \
  --payment-verification-key-file "$ca_vkey" > "$ca_vkey_hash"

# Generate keys for each role
for i in $(seq 1 $keys_per_role); do
  # Define file paths for voter, delegation, and member keys
  voter_skey="./keys/cc-manager/voter/voter-$i.skey"
  voter_vkey="./keys/cc-manager/voter/voter-$i.vkey"
  voter_vkey_hash="./keys/cc-manager/voter/voter-$i.keyHash"
  delegation_skey="./keys/cc-manager/delegation/delegation-$i.skey"
  delegation_vkey="./keys/cc-manager/delegation/delegation-$i.vkey"
  delegation_vkey_hash="./keys/cc-manager/delegation/delegation-$i.keyhash"
  member_skey="./keys/cc-manager/member/member-$i.skey"
  member_vkey="./keys/cc-manager/member/member-$i.vkey"
  member_vkey_hash="./keys/cc-manager/member/member-$i.keyhash"

  # Generate keys / keyhashes for each role
  container_cli address key-gen \
    --signing-key-file "$voter_skey" \
    --verification-key-file "$voter_vkey"

  container_cli address key-hash \
    --payment-verification-key-file "$voter_vkey" > "$voter_vkey_hash"

  container_cli address key-gen \
    --signing-key-file "$delegation_skey" \
    --verification-key-file "$delegation_vkey"

  container_cli address key-hash \
    --payment-verification-key-file "$delegation_vkey" > "$delegation_vkey_hash"

  container_cli address key-gen \
    --signing-key-file "$member_skey" \
    --verification-key-file "$member_vkey"

  container_cli address key-hash \
    --payment-verification-key-file "$member_vkey" > "$member_vkey_hash"

  # Create PEM files for each role
  create_pem "$voter_skey" "./keys/cc-manager/voter/voter-$i-private.pem"
  create_pem "$delegation_skey" "./keys/cc-manager/delegation/delegation-$i-private.pem"
  create_pem "$member_skey" "./keys/cc-manager/member/member-$i-private.pem"

  # Create CSR files for each role
  openssl req -new -key "./keys/cc-manager/voter/voter-$i-private.pem" -out "./keys/cc-manager/voter/voter-$i.csr" -subj $key_subject
  openssl req -new -key "./keys/cc-manager/delegation/delegation-$i-private.pem" -out "./keys/cc-manager/delegation/delegation-$i.csr" -subj $key_subject
  openssl req -new -key "./keys/cc-manager/member/member-$i-private.pem" -out "./keys/cc-manager/member/member-$i.csr" -subj $key_subject

done

# Create PEM file for CA role
create_pem "$ca_skey" "./keys/cc-manager/ca/ca-private.pem"