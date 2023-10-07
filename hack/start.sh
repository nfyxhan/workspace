#!/bin/sh

data_path=${data_path:-/data}

echo docker run -itd --security-opt=seccomp:unconfined \
    ${DOCKER_OPTION} \
    --name workspace \
    -v ${data_path}:${data_path} \
    "${FULL_IMAGE}" \
    /bin/bash