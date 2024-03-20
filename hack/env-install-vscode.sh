#!/bin/sh

if [[ "${RUN_PLATFORM}" == "amd64" ]] ; then
  export CODE_SERVER_VERSION=4.16.1
else
  export CODE_SERVER_VERSION=4.20.1
fi
