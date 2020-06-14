#!/usr/bin/env bash

set -e

# For now, until refactor branch is merged
RCN_DOCKER_TAG="${RCN_DOCKER_TAG:-latest}"
RCN_ANSIBLE_BRANCH="${RCN_ANSIBLE_BRANCH:-raccoon-refactor}"

################################################################################

export RCN_ANSIBLE_BRANCH="${RCN_ANSIBLE_BRANCH:-master}"
export RCN_DOCKER_CONTAINER="${RCN_DOCKER_CONTAINER:-mageops-raccoon-build}"
export RCN_DOCKER_IMAGE="${RCN_DOCKER_IMAGE:-mageops/raccoon}"
export RCN_DOCKER_TAG="${RCN_DOCKER_TAG:-${RCN_ANSIBLE_BRANCH}}"

################################################################################

env | grep '^RCN_'

################################################################################

rcn-docker-container-run() {

    echo " * Start provisioning container"

    ! docker container inspect "$RCN_DOCKER_CONTAINER" &>/dev/null  \
        || ( docker kill "$RCN_DOCKER_CONTAINER" && docker rm "$RCN_DOCKER_CONTAINER" ) \
        || true

    docker run \
        --detach \
        --interactive \
        --tty \
        --tmpfs /tmp:exec \
        --tmpfs /run:exec \
        --volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
        --name "$RCN_DOCKER_CONTAINER" \
            "${RCN_DOCKER_IMAGE}-base-ansible"

    echo " * Wait until container is healthy"

    while ! docker ps --filter name="$RCN_DOCKER_CONTAINER" --filter health=healthy --format '{{ .Names }}' | grep "$RCN_DOCKER_CONTAINER" >/dev/null; do
        echo " - [$RCN_DOCKER_CONTAINER] $(docker ps --filter name="$RCN_DOCKER_CONTAINER" --format '{{ .Status }}')"
        sleep 0.5s
    done
}

################################################################################

rcn-docker-push() {
    [ -z "$DOCKER_PASSWORD" ] || echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
    docker push "$@"
}