#!/bin/bash

echo "Setting up cloudbreak infrastructure ..."

if [ ! -f env_props.sh ] ;then
  cp env_props.sh.sample env_props.sh
  cat <<EOF
=================================================
= Please fill missing variables in:env_props.sh =
=================================================
EOF
  exit
fi
# check the environment
source env_props.sh

check-docker-version() {
  DOCKER_VER=$(docker version|sed -n "/Server version/ {s/.*:.//; s/\.//gp}")
  if [ $DOCKER_VER -lt 111 ]; then
    cat <<EOF

=============================================
= ERROR                                     =
= You are using an old version of Docker =
= Please upgrade it to at least 1.1.1       =
=============================================
EOF
    exit -1
  fi
}

check-docker-version

: ${CB_AZURE_IMAGE_URI:="http://vmdepotneurope.blob.core.windows.net/linux-community-store/community-62091-c0713e8c-bc6d-44cc-a751-bf9c35603340-5.vhd"}
: ${CB_MANAGEMENT_CONTEXT_PATH:="/"}
: ${CB_BLUEPRINT_DEFAULTS:="lambda-architecture,multi-node-hdfs-yarn,single-node-hdfs-yarn"}
: ${CB_SNS_SSL:="false"}
: ${CB_DB_ENV_DB:="cloudbreak"}
: ${CB_HBM2DDL_STRATEGY:="create"}
: ${CB_API_PORT:=8080}
: ${CB_DB_ENV_USER:=cloudbreak}
: ${CB_DB_ENV_PASS:=cloudbreak}
: ${CB_CLIENT_ID:=cloudbreak}
: ${CB_CLIENT_SECRET:=cloudbreaksecret}
: ${CB_SMTP_SENDER_PORT=587}
: ${CB_SMTP_SENDER_FROM=no-reply@sequenceiq.com}

: ${ULU_OAUTH_REDIRECT_URI=http://localhost:3000/authorize}
: ${ULU_OAUTH_CLIENT_SECRET=uluwatusecret}
: ${ULU_OAUTH_CLIENT_ID=uluwatu}

: ${SL_CLIENT_ID=sultans}
: ${SL_CLIENT_SECRET=sultanssecret}
: ${SL_PORT=8081}
: ${SL_ZIP=master}

: ${UAA_DOCKER_IMAGE_TAG:=latest}
: ${CB_DOCKER_IMAGE_TAG:=latest}
: ${ULU_DOCKER_IMAGE_TAG:=latest}
: ${SULTANS_DOCKER_IMAGE_TAG:=latest}

docker pull sequenceiq/uaa:$UAA_DOCKER_IMAGE_TAG
docker pull sequenceiq/uluwatu:$ULU_DOCKER_IMAGE_TAG
docker pull sequenceiq/cloudbreak:$CB_DOCKER_IMAGE_TAG
docker pull sequenceiq/sultans:$SULTANS_DOCKER_IMAGE_TAG

source check_env.sh

if [ $? -ne 0 ]; then
  exit 1;
fi

# Removes previous containers
docker inspect postgresql &>/dev/null && docker rm -f postgresql

# Start a postgres database docker container
docker run -d --name="postgresql" \
  -p 5432:5432 \
  -e "USER=$CB_DB_ENV_USER" \
  -e "DB=$CB_DB_ENV_DB" \
  -e "PASS=$CB_DB_ENV_PASS"  \
  paintedfox/postgresql

timeout=10
echo "Wait $timeout seconds for the POSTGRES DB to start up"
sleep $timeout

docker inspect uaadb &>/dev/null && docker rm -f uaadb

docker run -d --name="uaadb"  -e USER="uaaadmin" -e DB="uaa" -e PASS="uaaadmin" paintedfox/postgresql
echo "Wait $timeout seconds for the UAA DB to start up"
sleep $timeout

docker inspect uaa &>/dev/null && docker rm -f uaa

docker run -d --name="uaa" --link uaadb:db sequenceiq/uaa:$UAA_DOCKER_IMAGE_TAG
timeout=20
echo "Wait $timeout seconds for the UAA to start up"
sleep $timeout

# Removes previous containers
docker inspect cloudbreak &>/dev/null &&  docker rm -f cloudbreak

UAA_ADDR=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' uaa)

# Start the CLoudbreak application docker container
docker run -d --name="cloudbreak" \
-e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" \
-e "AWS_SECRET_KEY=$AWS_SECRET_KEY" \
-e "CB_HBM2DDL_STRATEGY=$CB_HBM2DDL_STRATEGY" \
-e "CB_SMTP_SENDER_USERNAME=$CB_SMTP_SENDER_USERNAME" \
-e "CB_SMTP_SENDER_PASSWORD=$CB_SMTP_SENDER_PASSWORD" \
-e "CB_SMTP_SENDER_HOST=$CB_SMTP_SENDER_HOST" \
-e "CB_SMTP_SENDER_PORT=$CB_SMTP_SENDER_PORT" \
-e "CB_SMTP_SENDER_FROM=$CB_SMTP_SENDER_FROM" \
-e "CB_AZURE_IMAGE_URI=$CB_AZURE_IMAGE_URI" \
-e "CB_BLUEPRINT_DEFAULTS=$CB_BLUEPRINT_DEFAULTS" \
-e "CB_SNS_SSL=$CB_SNS_SSL" \
-e "CB_MANAGEMENT_CONTEXT_PATH=$CB_MANAGEMENT_CONTEXT_PATH" \
-e "CB_CLIENT_ID=$CB_CLIENT_ID" \
-e "CB_CLIENT_SECRET=$CB_CLIENT_SECRET" \
-e "CB_IDENTITY_SERVER_URL=http://$UAA_ADDR:8080" \
--link postgresql:cb_db \
-p $CB_API_PORT:8080 \
sequenceiq/cloudbreak:$CB_DOCKER_IMAGE_TAG bash

# we are starting the wait_for_cloudbreak_api.sh script in a container
# using the same network interface as cloudbreak, so it can check
# simple on 127.0.0.1 event in a different container
docker run -it --rm \
  --net=container:cloudbreak \
  --entrypoint /bin/bash \
  sequenceiq/cloudbreak:$CB_DOCKER_IMAGE_TAG -c /wait_for_cloudbreak_api.sh

# Removes previous containers
docker inspect sultans &>/dev/null && docker rm -f sultans

CB_ADDR=$(docker inspect -f "{{.NetworkSettings.IPAddress}}" cloudbreak)

docker run -d --name="sultans" \
-e "SL_CLIENT_ID=$SL_CLIENT_ID" \
-e "SL_CLIENT_SECRET=$SL_CLIENT_SECRET" \
-e "SL_UAA_ADDRESS=http://$UAA_ADDR:8080" \
-e "SL_SMTP_SENDER_HOST=$CB_SMTP_SENDER_HOST" \
-e "SL_SMTP_SENDER_PORT=$CB_SMTP_SENDER_PORT" \
-e "SL_SMTP_SENDER_USERNAME=$CB_SMTP_SENDER_USERNAME" \
-e "SL_SMTP_SENDER_PASSWORD=$CB_SMTP_SENDER_PASSWORD" \
-e "SL_SMTP_SENDER_FROM=$CB_SMTP_SENDER_FROM" \
-e "SL_CB_ADDRESS=http://$CB_ADDR:8080" \
-e "SL_ZIP=$SL_ZIP" \
-p $SL_PORT:8080 sequenceiq/sultans:$SULTANS_DOCKER_IMAGE_TAG

# Removes previous containers
docker inspect uluwatu &>/dev/null && docker rm -f uluwatu

SULTANS_ADDR=$(docker inspect -f "{{.NetworkSettings.IPAddress}}" sultans)

docker run -d --name="uluwatu" \
-e "ULU_CLOUDBREAK_ADDRESS=http://$CB_ADDR:8080" \
-e "ULU_IDENTITY_ADDRESS=http://$UAA_ADDR:8080" \
-e "ULU_OAUTH_CLIENT_ID=$ULU_OAUTH_CLIENT_ID" \
-e "ULU_OAUTH_CLIENT_SECRET=$ULU_OAUTH_CLIENT_SECRET" \
-e "ULU_OAUTH_REDIRECT_URI=$ULU_OAUTH_REDIRECT_URI" \
-e "ULU_SULTANS_ADDRESS=http://$SULTANS_ADDR:8080" \
-p 3000:3000 sequenceiq/uluwatu:$ULU_DOCKER_IMAGE_TAG

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

ULUWATU_IP=$(docker inspect -f "{{.NetworkSettings.IPAddress}}" uluwatu)

cat <<EOF
=============================================
Cloudbreak is running on: $CB_ADDR:$CB_API_PORT
Uluwatu is running on: localhost:3000
        username: admin@sequenceiq.com
        password: seqadmin
Sultans is running on: $SULTANS_ADDR:$SL_PORT
=============================================
EOF
