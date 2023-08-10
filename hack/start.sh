#!/bin/sh

addr=${ADDR:-0.0.0.0}
port=${PORT:-9999}

function start_workspace() {
    docker run -it --security-opt=seccomp:unconfined  -p ${port}:${port} -v /data:/data ${FULL_IMAGE} sh
}

function start_code_server() {
    password=`uuidgen`
    code-server --bind-addr ${addr}:${port} /data/src
}

function install_go_tools() {
    go install github.com/swaggo/swag/cmd/swag@v1.8.9
    go install github.com/golang/mock/mockgen@v1.6.0
    go install golang.org/x/tools/cmd/stringer@v0.3.0
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.50.1
}
