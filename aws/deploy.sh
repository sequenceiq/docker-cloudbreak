#!/bin/bash

export CB_DIR=/usr/local/cloudbreak
export START_SCRIPT_NAME=start_cb.sh
export START_CB_SCRIPT=$CB_DIR/$START_SCRIPT_NAME
export HOST_ADDRESS=http://$(curl -s -m 5 http://169.254.169.254/latest/meta-data/public-ipv4)

# download check_env.sh
curl -Lo $CB_DIR/check_env.sh https://raw.githubusercontent.com/sequenceiq/docker-cloudbreak/test/check_env.sh

# download uaa.yml template
curl -Lo $CB_DIR/uaa.tmp.yml https://raw.githubusercontent.com/sequenceiq/docker-cloudbreak/test/uaa.tmp.yml

# fix redirect uri
cd $CB_DIR && sed "s|HOST_ADDRESS|"$HOST_ADDRESS"|" uaa.tmp.yml > uaa.yml

# download the start script
curl -Lo $START_CB_SCRIPT https://raw.githubusercontent.com/sequenceiq/docker-cloudbreak/test/konzul-cb.sh
chmod +x $START_CB_SCRIPT

# deploy
cd $CB_DIR && ./$START_SCRIPT_NAME
