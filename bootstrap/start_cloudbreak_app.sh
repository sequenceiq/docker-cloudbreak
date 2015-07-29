#!/bin/bash

: ${SECURE_RANDOM:=true}

echo "Starting the Cloudbreak application..."

if [ "$SECURE_RANDOM" == "false" ]; then
  CB_PARAMS=-Djava.security.egd=file:/dev/./urandom
fi

java $CB_PARAMS -jar /cloudbreak.jar
