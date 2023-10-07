#!/bin/sh

port=${port:-9999}
addr=${addr:-0.0.0.0}
data_path=${data_path:-/data}

echo docker run -itd --security-opt=seccomp:unconfined \
    ${DOCKER_OPTION} \
    --name workspace \
    -p ${port}:${port} \
    -v ${data_path}:${data_path} \
    "${FULL_IMAGE}" \
    /bin/bash -c '"set -e && code-server --bind-addr ${addr}:${port} '${data_path}'"'
