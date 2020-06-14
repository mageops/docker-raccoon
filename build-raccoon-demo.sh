#!/usr/bin/env bash

set -e

. build-config.sh

################################################################################

echo " * Provision container with ansible"

rcn-docker-container-run \
    "${RCN_DOCKER_IMAGE}"

docker exec \
    --tty \
    "$RCN_DOCKER_CONTAINER" \
        /usr/local/bin/mageops-update

docker exec \
    --tty \
    "$RCN_DOCKER_CONTAINER" \
        /usr/local/bin/mageops-playbook raccoon.demo

################################################################################

echo " * Commit the demo raccoon container"

docker stop \
    "$RCN_DOCKER_CONTAINER"
docker commit \
    "$RCN_DOCKER_CONTAINER" \
    "$RCN_DOCKER_IMAGE-demo"
docker tag \
    "$RCN_DOCKER_IMAGE-demo" \
    "$RCN_DOCKER_IMAGE-demo:$RCN_DOCKER_TAG"
docker rm \
    "$RCN_DOCKER_CONTAINER"

################################################################################

echo " * Push the image"

rcn-docker-push "$RCN_DOCKER_IMAGE-demo:$RCN_DOCKER_TAG"