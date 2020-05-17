#!/bin/bash

CONSENSUS="$1"

if [ $CONSENSUS = "poet" ]; then
    docker exec sawtooth-shell-default bash -c '
        sawadm keygen --force && \
        sawset proposal create \
          -k /etc/sawtooth/keys/validator.priv \
          sawtooth.consensus.algorithm.name=PoET \
          sawtooth.consensus.algorithm.version=0.1 \
          sawtooth.poet.report_public_key_pem="$(cat /etc/sawtooth/simulator_rk_pub.pem)" \
          sawtooth.poet.valid_enclave_measurements=$(poet enclave measurement) \
          sawtooth.poet.valid_enclave_basenames=$(poet enclave basename) \
          sawtooth.poet.block_claim_delay=1 \
          sawtooth.poet.key_block_claim_limit= 100000 \
          sawtooth.poet.ztest_minimum_win_count=999999999 \
          -o config.batch && \
        sawset proposal create \
         -k /etc/sawtooth/keys/validator.priv \
          sawtooth.poet.target_wait_time=5 \
             sawtooth.poet.initial_wait_time=25 \
             sawtooth.publisher.max_batches_per_block=100 \
          -o poet-settings.batch  \'
fi;

if [ $CONSENSUS = "devmode" ]; then
    docker exec sawtooth-shell-default bash -c '
        sawset proposal create -k /etc/sawtooth/keys/validator.priv \
        sawtooth.consensus.algorithm.name=Devmode \
        sawtooth.consensus.algorithm.version=0.1 \
        -o config.batch'
fi;
