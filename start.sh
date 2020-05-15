#!/bin/bash

CONSENSUS="$1"
CODE="bash -c \"\
        sawadm keygen --force && \
        mkdir -p /poet-shared/validator || true && \
        cp -a /etc/sawtooth/keys /poet-shared/validator/ && \
        while [ ! -f /poet-shared/poet-enclave-measurement ]; do sleep 1; done && \
        while [ ! -f /poet-shared/poet-enclave-basename ]; do sleep 1; done && \
        while [ ! -f /poet-shared/poet.batch ]; do sleep 1; done && \
        cp /poet-shared/poet.batch / && \
        sawset genesis \
          -k /etc/sawtooth/keys/validator.priv \
          -o config-genesis.batch && \
        sawset proposal create \
          -k /etc/sawtooth/keys/validator.priv \
          sawtooth.consensus.algorithm.name=PoET \
          sawtooth.consensus.algorithm.version=0.1 \
          sawtooth.poet.report_public_key_pem=\
          \\\"$$(cat /poet-shared/simulator_rk_pub.pem)\\\" \
          sawtooth.poet.valid_enclave_measurements=$$(cat /poet-shared/poet-enclave-measurement) \
          sawtooth.poet.valid_enclave_basenames=$$(cat /poet-shared/poet-enclave-basename) \
          -o config.batch && \
        sawset proposal create \
          -k /etc/sawtooth/keys/validator.priv \
             sawtooth.poet.target_wait_time=5 \
             sawtooth.poet.initial_wait_time=25 \
             sawtooth.publisher.max_batches_per_block=100 \
          -o poet-settings.batch && \
        sawadm genesis \
          config-genesis.batch config.batch poet.batch poet-settings.batch && \
        sawtooth-validator -v \
          --bind network:tcp://eth0:8800 \
          --bind component:tcp://eth0:4004 \
          --bind consensus:tcp://eth0:5050 \
          --peering static \
          --endpoint tcp://validator:8800 \
          --scheduler parallel \
          --network-auth trust
    \""
if [ $CONSENSUS = "pbft" ]; then
   CODE="bash -c \"
        if [ -e /pbft-shared/validators/validator.priv ]; then
          cp /pbft-shared/validators/validator.pub /etc/sawtooth/keys/validator.pub
          cp /pbft-shared/validators/validator.priv /etc/sawtooth/keys/validator.priv
        fi &&
        if [ ! -e /etc/sawtooth/keys/validator.priv ]; then
          sawadm keygen
          mkdir -p /pbft-shared/validators || true
          cp /etc/sawtooth/keys/validator.pub /pbft-shared/validators/validator-0.pub
          cp /etc/sawtooth/keys/validator.priv /pbft-shared/validators/validator-0.priv
        fi &&
        if [ ! -e config-genesis.batch ]; then
          sawset genesis -k /etc/sawtooth/keys/validator.priv -o config-genesis.batch
        fi &&
        while [[ ! -f /pbft-shared/validators/validator-1.pub ]];
        do sleep 1; done
        echo sawtooth.consensus.pbft.members=\\['\"'$$(cat /pbft-shared/validators/validator.pub)'\"'\\] &&
        if [ ! -e config.batch ]; then
         sawset proposal create \
            -k /etc/sawtooth/keys/validator.priv \
            sawtooth.consensus.algorithm.name=pbft \
            sawtooth.consensus.algorithm.version=1.0 \
                        sawtooth.consensus.pbft.members=\\['\"'$$(cat /pbft-shared/validators/validator.pub)'\"'\\] \
            sawtooth.publisher.max_batches_per_block=1200 \
            -o config.batch
        fi &&
        if [ ! -e /var/lib/sawtooth/genesis.batch ]; then
          sawadm genesis config-genesis.batch config.batch
        fi &&
        if [ ! -e /root/.sawtooth/keys/my_key.priv ]; then
          sawtooth keygen my_key
        fi &&
        sawtooth-validator -vv \
          --endpoint tcp://validator-0:8800 \
          --bind component:tcp://eth0:4004 \
          --bind consensus:tcp://eth0:5050 \
          --bind network:tcp://eth0:8800 \
          --scheduler parallel \
          --peering static \
          --maximum-peer-connectivity 10000
      \" "
fi;

if [ $CONSENSUS = "devmode" ]; then

CODE="sawadm keygen \
        sawtooth keygen my_key \
        sawset genesis -k /root/.sawtooth/keys/my_key.priv \
        sawset proposal create -k /root/.sawtooth/keys/my_key.priv \
        sawtooth.consensus.algorithm.name=Devmode \
        sawtooth.consensus.algorithm.version=0.1 \
        -o config.batch \
        sawadm genesis config-genesis.batch config.batch\
        sawtooth-validator -vv \
          --endpoint tcp://validator:8800 \
          --bind component:tcp://eth0:4004 \
          --bind network:tcp://eth0:8800 \
          --bind consensus:tcp://eth0:5050" 
fi;

export CMD=$CODE

docker-compose up 
