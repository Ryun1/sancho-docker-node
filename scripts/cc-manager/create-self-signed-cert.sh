#!/bin/sh

# Define CA key file paths
days=3650

# Base directory roots
base_ca_dir="./keys/cc-manager/ca/"
key_subject="/C=US/ST=x/L=x/O=IntersectMBO/OU=x/CN=x"

# Create self-signed CA certificate
openssl req -x509 -new -key "$base_ca_dir"ca-private.pem -days "$days" -out "$base_ca_dir"ca-cert.pem -subj "$key_subject"