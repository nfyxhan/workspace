#!/bin/sh

data_path=${data_path:-/data}
container=${container:-workspace}

echo docker run -itd --security-opt=seccomp:unconfined \
    ${DOCKER_OPTION} \
    --name ${container} \
    -v ${data_path}:${data_path} \
    "${FULL_IMAGE}" bash