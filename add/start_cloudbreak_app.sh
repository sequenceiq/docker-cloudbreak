#!/bin/bash

: ${CB_HOST_ADDR:=$(hostname -i)}

export CB_HOST_ADDR="http://$CB_HOST_ADDR:8080"
java -jar /cloudbreak.jar
