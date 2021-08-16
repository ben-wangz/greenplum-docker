#! /bin/bash

set -e
set -x

SCRIPT_DIRECOTRY=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ${SCRIPT_DIRECOTRY}/image.env

ARCH=amd64
IMAGE=${IMAGE_REPOSITORY}:${IMAGE_TAG_PREFIX}-linux-${ARCH}
docker buildx build --platform linux/${ARCH} --rm ${SCRIPT_DIRECOTRY}/docker \
    -f ${SCRIPT_DIRECOTRY}/docker/Dockerfile \
    -t ${IMAGE} \
    --build-arg CENTOS_SYSTEMD_TAG=${CENTOS_SYSTEMD_TAG} \
    --build-arg GREEN_PLUM_PACKAGE_URL=${GREEN_PLUM_PACKAGE_URL} \
    $@
