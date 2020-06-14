#!/usr/bin/env bash

set -e

. build-config.sh

################################################################################

echo " * Build fat centos container"

docker build . \
    --pull \
    --squash \
    --file Dockerfile.base-centos \
    --target base-centos \
    --tag "${RCN_DOCKER_IMAGE}-base-centos" \

docker tag \
    "$RCN_DOCKER_IMAGE-base-centos" \
    "$RCN_DOCKER_IMAGE-base-centos:$RCN_DOCKER_TAG"

################################################################################

echo " * Push the image"

rcn-docker-push "$RCN_DOCKER_IMAGE-base-centos:$RCN_DOCKER_TAG"