#!/bin/bash

CONSENSUS="$1"
VERSION="$2"

if [ $CONSENSUS = "poet" ]; then
    export CONFIG="sawtooth.consensus.algorithm.name=PoET \
            sawtooth.consensus.algorithm.version=$VERSION \
            sawtooth.poet.report_public_key_pem="$(cat * /etc/sawtooth/simulator_rk_pub.pem)" \
            sawtooth.poet.valid_enclave_measurements=$(poet enclave measurement) \
            sawtooth.poet.valid_enclave_basenames=$(poet enclave basename) \
            sawtooth.poet.block_claim_delay=1 \
            sawtooth.poet.key_block_claim_limit= 100000 \
            sawtooth.poet.ztest_minimum_win_count=999999999"

fi;

if [ $CONSENSUS = "pbft" ]; then
    export CONFIG="sawtooth.consensus.algorithm.name=pbft \
            sawtooth.consensus.algorithm.version=$VERSION \
            sawtooth.consensus.pbft.members=[]"
fi;

if [ $CONSENSUS = "raft" ]; then
    export CONFIG="sawtooth.consensus.algorithm.name=raft \
            sawtooth.consensus.algorithm.version=$VERSION \
            sawtooth.consensus.raft.peers=[]"
fi;

if [ $CONSENSUS = "devmode" ]; then
    export CONFIG="sawtooth.consensus.algorithm.name=Devmode \
            sawtooth.consensus.algorithm.version=$VERSION "
fi;

export CMD="sawadm keygen
          sawtooth keygen my_key
          sawset genesis -k /root/.sawtooth/keys/my_key.priv
          sawset proposal create -k /root/.sawtooth/keys/my_key.priv \
          $CONFIG \
            -o config.batch
          sawadm genesis config-genesis.batch config.batch"

docker-compose up

# echo $CMD 
