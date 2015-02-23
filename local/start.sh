#!/bin/bash +x

#Run terraform script
export HOST_ADDRESS=http://192.168.1.144
cd .. && sed "s|HOST_ADDRESS|"$HOST_ADDRESS"|" uaa.tmp.yml > uaa.yml && ./konzul-cb.sh
