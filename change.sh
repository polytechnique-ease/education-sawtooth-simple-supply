#!/bin/bash

CONSENSUS="$1"

if [ $CONSENSUS = "devmode" ]; then
    docker exec sawtooth-validator-default-0 bash -c '
          sawset proposal create -k /etc/sawtooth/keys/validator.priv \
            sawtooth.consensus.algorithm.name=Devmode \
            sawtooth.consensus.algorithm.version=0.1 \
            --url http://rest-api-0:8008 
        '
fi;

if [ $CONSENSUS = "raft" ]; then
    docker exec sawtooth-validator-default-0 bash -c '
        sawset proposal create -k /etc/sawtooth/keys/validator.priv \
          sawtooth.consensus.algorithm.name=raft \
          sawtooth.consensus.algorithm.version=0.1 \
          sawtooth.consensus.raft.peers=[\""$(cat /etc/sawtooth/keys/validator.pub)\""] \
          --url http://rest-api-0:8008 && \
        sawset proposal create -k /etc/sawtooth/keys/validator.priv \
          --url http://rest-api-0:8008 \
          sawtooth.consensus.raft.heartbeat_tick=2 \
          sawtooth.consensus.raft.election_tick=20 \
          sawtooth.consensus.raft.period=3000 \
          sawtooth.publisher.max_batches_per_block=100 
      '
fi;

# docker logs -f sawtooth-validator

# docker restart sawtooth-validator-default-0 && docker exec sawtooth-validator-default-0 bash -c 'sawtooth settings list --url http://rest-api-0:8008'

if [ $CONSENSUS = "pbft" ]; then
    docker exec sawtooth-validator-default-0 bash -c '
        sawset proposal create -k /etc/sawtooth/keys/validator.priv \
          --url http://rest-api-0:8008 \
          sawtooth.consensus.algorithm.name=pbft \
          sawtooth.consensus.algorithm.version=0.1 \
          sawtooth.consensus.pbft.members=[\""$(cat /poet-shared/validators/validator-0.pub)\"",\""$(cat /poet-shared/validators/validator-1.pub)\"",\""$(cat /poet-shared/validators/validator-2.pub)\"",\""$(cat /poet-shared/validators/validator-3.pub)\"",\""$(cat /poet-shared/validators/validator-4.pub)\""]
      '
fi;

if [ $CONSENSUS = "poet" ]; then
    docker exec sawtooth-validator-default-0 bash -c '
        sawset proposal create \
            -k /etc/sawtooth/keys/validator.priv \
            sawtooth.consensus.algorithm.name=PoET \
            sawtooth.consensus.algorithm.version=0.1 \
            sawtooth.poet.report_public_key_pem=\""$(cat /poet-shared/simulator_rk_pub.pem)\"" \
            sawtooth.poet.valid_enclave_measurements=$(cat /poet-shared/poet-enclave-measurement) \
            sawtooth.poet.valid_enclave_basenames=$(cat /poet-shared/poet-enclave-basename) \
            --url http://rest-api-0:8008 && \
          sawset proposal create \
            -k /etc/sawtooth/keys/validator.priv \
            sawtooth.poet.target_wait_time=5 \
            sawtooth.poet.initial_wait_time=25 \
            sawtooth.publisher.max_batches_per_block=100 \
            --url http://rest-api-0:8008
      '
fi;

# docker restart $(docker ps -aq)
# docker start sawtooth-validator-default-0 && docker exec sawtooth-validator-default-0 bash -c 'rm /var/lib/sawtooth/genesis.batch'
# docker exec sawtooth-validator-default-0 bash -c 'cat /etc/sawtooth/keys/validator.pub'
# docker exec sawtooth-validator-default-0 bash -c 'cat /root/.sawtooth/keys/my_key.pub'

