#!/bin/sh

set -e

DOCKER_TAG="latest" # For now, until refactor branch is merged

################################################################################

export ANSIBLE_BRANCH="${ANSIBLE_BRANCH:-raccoon-refactor}"
export DOCKER_CONTAINER="${DOCKER_CONTAINER:-mageops-raccoon-build}"
export DOCKER_IMAGE="${DOCKER_IMAGE:-mageops/raccoon}"
export DOCKER_TAG="${DOCKER_TAG:-${ANSIBLE_BRANCH}}"

################################################################################

echo " * Build fat centos container"

docker build . \
    --pull \
    --squash \
    --file Dockerfile.base-centos \
    --target base-centos \
    --tag "${DOCKER_IMAGE}-base-centos" \

docker tag \
    "$DOCKER_IMAGE-base-centos" \
    "$DOCKER_IMAGE-base-centos:$DOCKER_TAG"

################################################################################

echo " * Build base ansible container"

docker build . \
    --file Dockerfile.base-ansible \
    --target base-ansible \
    --tag "${DOCKER_IMAGE}-base-ansible" \
    --build-arg "ANSIBLE_BRANCH=${ANSIBLE_BRANCH}" \
    --build-arg "BASE_IMAGE=$DOCKER_IMAGE-base-centos" \
    --squash \
    --no-cache

docker tag \
    "$DOCKER_IMAGE-base-ansible" \
    "$DOCKER_IMAGE-base-ansible:$DOCKER_TAG"

################################################################################

echo " * Start provisioning container"

! docker container inspect "$DOCKER_CONTAINER" &>/dev/null  \
    || ( docker kill "$DOCKER_CONTAINER" && docker rm "$DOCKER_CONTAINER" ) \
    || true

docker run \
    --detach \
    --interactive \
    --tty \
    --tmpfs /tmp:exec \
    --tmpfs /run:exec \
    --volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
    --name "$DOCKER_CONTAINER" \
        "${DOCKER_IMAGE}-base-ansible"

################################################################################

echo " * Wait until container is healthy"

while ! docker ps --filter name="$DOCKER_CONTAINER" --filter health=healthy --format '{{ .Names }}' | grep "$DOCKER_CONTAINER" >/dev/null; do
    echo " - [$DOCKER_CONTAINER] $(docker ps --filter name="$DOCKER_CONTAINER" --format '{{ .Status }}')"
    sleep 0.5s
done

################################################################################

echo " * Provision container with ansible"

docker exec \
    --tty \
    "$DOCKER_CONTAINER" \
        /usr/local/bin/mageops-playbook raccoon

################################################################################

echo " * Commit the base raccoon container"

# Pausing it not enough! We want the system to be in clean shutdown state.
docker stop \
    "$DOCKER_CONTAINER"
docker commit \
    "$DOCKER_CONTAINER" \
    "$DOCKER_IMAGE"
docker tag \
    "$DOCKER_IMAGE" \
    "$DOCKER_IMAGE:$DOCKER_TAG"

################################################################################

echo " * Start the container back and provision demo"

docker start \
    "$DOCKER_CONTAINER"

sleep 5s

docker exec \
    --tty \
    "$DOCKER_CONTAINER" \
        /usr/local/bin/mageops-playbook raccoon.demo

################################################################################

echo " * Commit the demo raccoon container"

docker stop \
    "$DOCKER_CONTAINER"
docker commit \
    "$DOCKER_CONTAINER" \
    "$DOCKER_IMAGE-demo"
docker tag \
    "$DOCKER_IMAGE-demo" \
    "$DOCKER_IMAGE-demo:$DOCKER_TAG"

################################################################################

echo " * Remove the container"
docker rm \
    "$DOCKER_CONTAINER"

################################################################################

echo " * Push the built containers"

[ -z "$DOCKER_PASSWORD" ] || echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

docker push "$DOCKER_IMAGE-base-centos:$DOCKER_TAG"
docker push "$DOCKER_IMAGE-base-ansible:$DOCKER_TAG"
docker push "$DOCKER_IMAGE-demo:$DOCKER_TAG"
docker push "$DOCKER_IMAGE:$DOCKER_TAG"



