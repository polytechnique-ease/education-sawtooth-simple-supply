#!/bin/bash

docker-compose -f poet.yaml up -d && docker-compose -f default.yaml up -d 

# && docker-compose -f dev.yaml up -d 

# docker-compose -f poet.yaml up -d && docker-compose -f default.yaml up -d