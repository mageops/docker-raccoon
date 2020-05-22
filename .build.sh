#!/bin/sh

echo " * Build container..."

docker build . -f Dockerfile.base -t mageops/raccoon-ansible-install

echo " * Run container..."

! docker top mageops-raccoon-build 2>/dev/null 1>/dev/null || docker kill mageops-raccoon-build

docker run \
    --rm \
    --interactive \
    --tty \
    --tmpfs /tmp:exec \
    --tmpfs /run \
    --volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
    --name mageops-raccoon-build \
        mageops/raccoon-ansible-install

echo " * Wait until container is healthy..."

while ! docker ps --filter name=mageops-raccoon-build --filter health=healthy --format '{{ .Names }}' | grep mageops-raccoon-build  >/dev/null; do
    echo " * Status: $(docker ps --filter name=mageops-raccoon-build --format '{{ .Status }}')"
    sleep 1s
done

