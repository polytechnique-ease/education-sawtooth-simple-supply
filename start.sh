#!/bin/bash
CONSENSUS="$1"

if [ $CONSENSUS = "poet" ]; then
    docker-compose -f poet.yaml up -d && docker-compose -f dev.yaml up -d
fi;

if [ $CONSENSUS = "devmode" ]; then
    docker-compose -f default.yaml up -d && docker-compose -f dev.yaml up -d
fi;
