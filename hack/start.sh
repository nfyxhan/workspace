#!/bin/sh

container=${container:-workspace}

echo docker run -itd --security-opt=seccomp:unconfined \
    ${DOCKER_OPTION} \
    --name ${container} \
    "${FULL_IMAGE}" bash