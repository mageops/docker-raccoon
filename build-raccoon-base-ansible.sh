#!/usr/bin/env bash

set -e

. build-config.sh

################################################################################

echo " * Build base ansible container"

docker build . \
    --pull \
    --file Dockerfile.base-ansible \
    --target base-ansible \
    --tag "${RCN_DOCKER_IMAGE}-base-ansible" \
    --build-arg "RCN_ANSIBLE_BRANCH=${RCN_ANSIBLE_BRANCH}" \
    --build-arg "BASE_IMAGE=$RCN_DOCKER_IMAGE-base-centos" \
    --squash \
    --no-cache

docker tag \
    "$RCN_DOCKER_IMAGE-base-ansible" \
    "$RCN_DOCKER_IMAGE-base-ansible:$RCN_DOCKER_TAG"

################################################################################

echo " * Push the image"

rcn-docker-push "$RCN_DOCKER_IMAGE-base-ansible:$RCN_DOCKER_TAG"
