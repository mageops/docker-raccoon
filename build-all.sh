#!/usr/bin/env bash

set -e

. build-config.sh

################################################################################

./build-raccoon-base-centos.sh
./build-raccoon-base-ansible.sh
./build-raccoon.sh
./build-raccoon-demo.sh