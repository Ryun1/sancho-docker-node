#!/bin/sh

# Base directory roots
base_dir="./keys/cc-manager/"
base_ca_dir="${base_dir}ca/"

# days for certificate validity per role
voter_cert_days=365 # 1 year
delegation_cert_days=3650 # 10 years
member_cert_days=3650 # 10 years

# Function to process CSR files and sign certificates
process_csrs() {
  local role_dir=$1
  local cert_days=$2

  for csr_file in "${role_dir}"/*.csr; do

    current_child=$(echo "$csr_file" | sed 's/\.csr$//')
    echo "\n##################################################"
    echo "\nReviewing certificate signing request (.csr) for $current_child\n"

    # TODO: Add more checks on each file here

    # Print the certificate request
    openssl req -in "$csr_file" -text -noout

    # Take input from user if they want to sign the certificate using CA key
    echo " "
    read -p "Do you want to sign the certificate for $csr_file? (yes/no): " input

    if [ "$input" = "yes" ]; then
      # Sign the certificate and save it back to the child directory
      openssl x509 -days "$cert_days" -req -in "$csr_file" -CA "${base_ca_dir}ca-cert.pem" -CAkey "${base_ca_dir}ca-private.pem" -out "${current_child}-cert.pem"
      echo "\nCertificate signed for $csr_file\n"
    elif [ "$input" = "no" ]; then
      # Reject the certificate
      echo "\nCertificate rejected for $csr_file"
      echo "Exiting script."
      exit 1
    else
      echo "\nInvalid input. Skipping $csr_file\n"
      echo "Exiting script."
      exit 1
    fi
  done
}

# Process CSRs for each role
process_csrs "${base_dir}voter" "$voter_cert_days"
process_csrs "${base_dir}delegation" "$delegation_cert_days"
process_csrs "${base_dir}member" "$member_cert_days"