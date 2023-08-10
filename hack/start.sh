#!/bin/sh

addr=${ADDR:-0.0.0.0}
port=${PORT:-9999}

function start_workspace() {
    docker run -it --security-opt=seccomp:unconfined  -p ${port}:${port} -v /data:/data ${FULL_IMAGE} sh
}

function start_code_server() {
    password=`uuidgen`
    code-server --bind-addr ${addr}:${port} --password ${password}
}
