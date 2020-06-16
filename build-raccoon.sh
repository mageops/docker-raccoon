#!/usr/bin/env bash

set -e

. build-config.sh

################################################################################

echo " * Provision container with ansible"

rcn-docker-container-run \
    "${RCN_DOCKER_IMAGE}-base-ansible"

rcn-docker-container-exec \
    /usr/local/bin/mageops-update

rcn-docker-container-exec \
    /usr/local/bin/mageops-playbook raccoon

rcn-docker-container-exec \
    /usr/local/bin/mageops-trim

################################################################################

echo " * Commit the base raccoon container"

# Pausing it not enough! We want the system to be in clean shutdown state.
docker stop \
    "$RCN_DOCKER_CONTAINER"
docker commit \
    "$RCN_DOCKER_CONTAINER" \
    "$RCN_DOCKER_IMAGE"
docker tag \
    "$RCN_DOCKER_IMAGE" \
    "$RCN_DOCKER_IMAGE:$RCN_DOCKER_TAG"
docker rm \
    "$RCN_DOCKER_CONTAINER"

################################################################################

echo " * Push the image"

rcn-docker-push "$RCN_DOCKER_IMAGE:$RCN_DOCKER_TAG"