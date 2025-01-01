#!/bin/sh

NETWORK=sanchonet envsubst < docker-compose.yml | docker-compose -f - down

NETWORK=preview envsubst < docker-compose.yml | docker-compose -f - down

NETWORK=preprod envsubst < docker-compose.yml | docker-compose -f - down