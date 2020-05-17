#!/bin/bash

docker-compose -f pbft.yaml up -d && docker-compose -f default.yaml up -d 

# && docker-compose -f dev.yaml up -d 

# && docker-compose -f pbft.yaml up -d