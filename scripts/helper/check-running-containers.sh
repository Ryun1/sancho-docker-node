#!/bin/sh

# Get the list of running containers
running_containers=$(docker ps --format '{{.Names}}')

# Convert the running containers to an array
IFS=$'\n' read -r -d '' -a running_containers <<< "$running_containers"

# Determine which container to use
if [ ${#running_containers[@]} -eq 1 ]; then
  echo "${running_containers[0]}"
elif [ ${#running_containers[@]} -gt 1 ]; then
  echo "Multiple running containers found. Please select one:"
  select container_name in "${running_containers[@]}"; do
    if [ -n "$container_name" ]; then
      echo "$container_name"
      break
    fi
  done
else
  echo "No running containers found from the predefined list."
  exit 1
fi