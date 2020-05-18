#!/bin/bash

CONSENSUS="$1"

if [ $CONSENSUS = "devmode" ]; then
    docker start sawtooth-devmode-engine-rust-default &&
    docker exec sawtooth-validator-default-0 bash -c '          

if [ ! -e /root/.sawtooth/keys/my_key.priv ]; then
            sawtooth keygen my_key
            sawset genesis -k /root/.sawtooth/keys/my_key.priv
          fi &&
          sawset proposal create -k /root/.sawtooth/keys/my_key.priv \
            sawtooth.consensus.algorithm.name=Devmode \
            sawtooth.consensus.algorithm.version=0.1 \
            --url http://rest-api-0:8008 
        '
fi;

if [ $CONSENSUS = "raft" ]; then
    docker exec sawtooth-validator bash -c '

        if [ ! -e /root/.sawtooth/keys/my_key.priv ]; then
          sawtooth keygen my_key
          sawset genesis -k /root/.sawtooth/keys/my_key.priv
        fi &&
        sawset proposal create -k /root/.sawtooth/keys/my_key.priv \
          sawtooth.consensus.algorithm.name=raft \
          sawtooth.consensus.algorithm.version=0.1 \
          sawtooth.consensus.raft.peers=[\""$(cat /etc/sawtooth/keys/validator.pub)\""] \
          --url http://rest-api-0:8008 && \
        sawset proposal create -k /root/.sawtooth/keys/my_key.priv \
          --url http://rest-api-0:8008 \

          sawtooth.consensus.raft.heartbeat_tick=2 \
          sawtooth.consensus.raft.election_tick=20 \
          sawtooth.consensus.raft.period=3000 \
          sawtooth.publisher.max_batches_per_block=100 
      '
fi;

# docker logs -f sawtooth-validator

# docker start sawtooth-validator && docker exec sawtooth-validator bash -c 'rm /var/lib/sawtooth/genesis.batch'

if [ $CONSENSUS = "pbft" ]; then

    docker exec sawtooth-validator bash -c '
        if [ ! -e /root/.sawtooth/keys/my_key.priv ]; then
          sawadm keygen 
          sawtooth keygen my_key
          sawset genesis -k /root/.sawtooth/keys/my_key.priv
        fi &&
        if [ ! -e /pbft-shared/validators/validator-0.pub ]; then
          mkdir -p /pbft-shared/validators || true
          cp /etc/sawtooth/keys/validator.pub /pbft-shared/validators/validator-0.pub
          cp /etc/sawtooth/keys/validator.priv /pbft-shared/validators/validator-0.priv
        fi &&
        sawset proposal create -k /root/.sawtooth/keys/my_key.priv \

          --url http://rest-api-0:8008 \
          sawtooth.consensus.algorithm.name=pbft \
          sawtooth.consensus.algorithm.version=0.1 \
          sawtooth.consensus.pbft.members=[\""$(cat /pbft-shared/validators/validator-0.pub)\"",\""$(cat /pbft-shared/validators/validator-1.pub)\"",\""$(cat /pbft-shared/validators/validator-2.pub)\"",\""$(cat /pbft-shared/validators/validator-3.pub)\"",\""$(cat /pbft-shared/validators/validator-4.pub)\""]

      '
fi;
# docker restart $(docker ps -aq) 



