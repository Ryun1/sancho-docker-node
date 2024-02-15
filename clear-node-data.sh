#!/bin/sh

# Remove database files
rm -rf ./node-db

# Recreate database files
mkdir ./node-db

# Add .gitignore back to the node-db directory
echo "# Ignore everything in this directory
*
# Except this file
!.gitignore" > ./node-db/.gitignore