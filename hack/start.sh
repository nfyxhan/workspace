#!/bin/sh

port=${port:-9999}
addr=${addr:-0.0.0.0}
data_path=${data_path:-/data}

echo docker run -itd --security-opt=seccomp:unconfined \
    --name workspace \
    -p ${port}:${port} \
    -p 80:80 \
    -v ${data_path}:${data_path} \
    "${FULL_IMAGE}" \
    code-server --bind-addr ${addr}:${port} /data
