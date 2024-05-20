#!/bin/sh

# Base directory roots
base_dir="./keys/cc-manager/"
base_ca_dir="${base_dir}ca/"

function sha256sum() { openssl sha256 "$@" | awk '{print $2}'; }

# Function to process CSR files and sign certificates
review_and_hash_certs() {
  local role_dir=$1

  for pem_file in "${role_dir}"/*-cert.pem; do

    current_child=$(echo "$pem_file" | sed 's/\.pem$//')
    echo "\n##################################################"
    echo "\nReviewing CA authorized certificate .pem for $current_child\n"

    # Print the certificate with who the CA is
    openssl x509 -in "$pem_file" -text -noout

    # TODO: Add more checks on each file here
    
    echo " "

    # Verify the certificate against the CAs certificate
    openssl verify -CAfile "$base_ca_dir"/ca-cert.pem "$pem_file"

    # Take input from user if they want to sign the certificate using CA key
    echo " "
    read -p "Are you happy to produce a hash of $pem_file? (yes/no): " input

    if [ "$input" = "yes" ]; then
      # make a hash file of the certificate
      openssl sha256 "$pem_file" | awk '{print $2}' > $current_child.hash

    elif [ "$input" = "no" ]; then
      # Reject the certificate
      echo "\nCertificate rejected for $pem_file"
      echo "Exiting script."
      exit 1
    else
      echo "\nInvalid input. Skipping $pem_file\n"
      echo "Exiting script."
      exit 1
    fi
  done
}

# Process pems for each role
echo "\nIterating through voter certificates"
review_and_hash_certs "${base_dir}voter" "$voter_cert_days"

echo "\nIterating through delegation certificates"
review_and_hash_certs "${base_dir}delegation" "$delegation_cert_days"

echo "\nIterating through member certificates"
review_and_hash_certs "${base_dir}member" "$member_cert_days"

