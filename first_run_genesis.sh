#!/bin/bash

set -e

  if [ -e /pbft-shared/validators/validator-0.priv ]; then
    cp /pbft-shared/validators/validator-0.pub /etc/sawtooth/keys/validator.pub
    cp /pbft-shared/validators/validator-0.priv /etc/sawtooth/keys/validator.priv
  fi

  if [ ! -e /etc/sawtooth/keys/validator.priv ]; then
    sawadm keygen
    mkdir -p /pbft-shared/validators || true
    cp /etc/sawtooth/keys/validator.pub /pbft-shared/validators/validator-0.pub
    cp /etc/sawtooth/keys/validator.priv /pbft-shared/validators/validator-0.priv
  fi

  if [ ! -e config-genesis.batch ]; then
    sawset genesis -k /etc/sawtooth/keys/validator.priv -o config-genesis.batch
  fi

  while [[ ! -f /pbft-shared/validators/validator-1.pub || \
            ! -f /pbft-shared/validators/validator-2.pub || \
            ! -f /pbft-shared/validators/validator-3.pub || \
            ! -f /pbft-shared/validators/validator-4.pub ]];
  do sleep 1; done

  PBFT_MEMBERS_STRING="[\"$(cat /pbft-shared/validators/validator-0.pub)\",\"$(cat /pbft-shared/validators/validator-1.pub)\",\"$(cat /pbft-shared/validators/validator-2.pub)\",\"$(cat /pbft-shared/validators/validator-3.pub)\",\"$(cat /pbft-shared/validators/validator-4.pub)\"]"

  echo "sawtooth.consensus.pbft.members=${PBFT_MEMBERS_STRING}"

  if [ ! -e config.batch ]; then
    sawset proposal create \
      -k /etc/sawtooth/keys/validator.priv \
      sawtooth.consensus.algorithm.name=pbft \
      sawtooth.consensus.algorithm.version=1.0 \
      sawtooth.consensus.pbft.members=${PBFT_MEMBERS_STRING} \
      sawtooth.publisher.max_batches_per_block=1200 \
      -o config.batch
  fi

  if [ ! -e /var/lib/sawtooth/genesis.batch ]; then
   sawadm genesis config-genesis.batch config.batch
  fi

  if [ ! -e /root/.sawtooth/keys/my_key.priv ]; then
   echo "test"
    sawtooth keygen my_key
  fi