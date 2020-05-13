#!/bin/bash

CONSENSUS="$1"

if [ $CONSENSUS = "poet" ]; then
    docker-compose -f default-down.yaml stop && docker-compose -f poet.yaml up -d
fi;

if [ $CONSENSUS = "devmode" ]; then
    docker-compose -f poet-down.yaml stop && docker-compose -f default.yaml up -d
fi;
