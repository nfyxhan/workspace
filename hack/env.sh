#!/bin/sh 

echo "TargetPlatform is ${TARGETPLATFORM}"

lscpu | grep Architecture

arch=`lscpu | grep Architecture | awk '{print $2}'`


if [[ "${TARGETPLATFORM}" == "linux/arm64" ]] ; then 
    export RUN_PLATFORM=arm64
else
    export RUN_PLATFORM=amd64
fi

if [[ "${arch}" != "x86_64" ]] ; then
    export RUN_PLATFORM=arm64
fi