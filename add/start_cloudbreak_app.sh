#!/bin/bash

: {$CB_HOST_ADDR:=$(hostname -i)}

java -jar /cloudbreak.jar
