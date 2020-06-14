#!/usr/bin/env bash

set -e

. build-config.sh

################################################################################

rcn-docker-container-run

echo " * Provision container with ansible"

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