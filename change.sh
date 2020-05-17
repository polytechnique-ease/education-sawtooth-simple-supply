#!/bin/bash

CONSENSUS="$1"

if [ $CONSENSUS = "poet" ]; then
    docker exec sawtooth-validator bash -c '
        sawadm keygen --force && \
        mkdir -p /poet-shared/validator-0 || true && \
        cp -a /etc/sawtooth/keys /poet-shared/validator-0/ && \
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
          sawtooth.poet.report_public_key_pem="$(cat /poet-shared/simulator_rk_pub.pem)" \
          sawtooth.poet.valid_enclave_measurements=$(cat /poet-shared/poet-enclave-measurement) \
          sawtooth.poet.valid_enclave_basenames=$(cat /poet-shared/poet-enclave-basename) \
          -o config.batch && \
        sawset proposal create \
          -k /etc/sawtooth/keys/validator.priv \
             sawtooth.poet.target_wait_time=5 \
             sawtooth.poet.initial_wait_time=25 \
             sawtooth.publisher.max_batches_per_block=100 \
          -o poet-settings.batch && \'
fi;

if [ $CONSENSUS = "devmode" ]; then
    docker exec sawtooth-validator bash -c '
        sawadm keygen --force
        sawtooth keygen --force my_key
        sawset genesis -k /root/.sawtooth/keys/my_key.priv
        sawset proposal create -k /root/.sawtooth/keys/my_key.priv \
        sawtooth.consensus.algorithm.name=Devmode \
        sawtooth.consensus.algorithm.version=0.1 \
        -o config.batch'
fi;
