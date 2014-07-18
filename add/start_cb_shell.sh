#!/bin/bash
# Collects environment variables
# - passed in as arguments from the docker run command (-e )
# - visible from the linked container

: {$CB_PORT_8080_TCP_ADDR:?"\$CB_PORT_8080_TCP_ADDR is not available."}
: {$CB_PORT_8080_TCP_PORT:?"\$CB_PORT_8080_TCP_PORT is not available."}
: {$CB_USER:?"\$CB_USER is not available."}
: {$CB_PASS:?"\$CB_PASS is not available."}

java -jar /cloudbreak-shell.jar \
--cloudbreak.host=$CB_PORT_8080_TCP_ADDR \
--cloudbreak.port=$CB_PORT_8080_TCP_PORT \
--cloudbreak.user=$CB_USER \
--cloudbreak.password=$CB_PASS
