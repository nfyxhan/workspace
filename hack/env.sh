#!/bin/sh 

echo "TargetPlatform is ${TARGETPLATFORM}"

if [[ "${TARGETPLATFORM}" == "linux/arm64" ]] ; then 
    export RUN_PLATFORM=arm64
else
    export RUN_PLATFORM=amd64
fi
