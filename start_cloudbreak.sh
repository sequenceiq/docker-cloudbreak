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
= You are using a too old version of Docker =
= Please upgrade it to at least 1.1.1       =
=============================================
EOF
    exit -1
  fi
}

check-docker-version

: ${CB_AZURE_IMAGE_URI:="http://vmdepoteastus.blob.core.windows.net/linux-community-store/community-62091-a59dcdc1-d82d-4e76-9094-27b8c018a4a1-5.vhd"}
: ${CB_MANAGEMENT_CONTEXT_PATH:="/"}
: ${CB_BLUEPRINT_DEFAULTS:="lambda-architecture,multi-node-hdfs-yarn,single-node-hdfs-yarn"}
: ${CB_SNS_SSL:="false"}
: ${CB_DB_ENV_DB:="cloudbreak"}
: ${CB_HBM2DDL_STRATEGY:="create"}
: ${CB_API_HOST:=cloudbreak.kom}
: ${CB_API_PORT:=8080}
: ${CB_UI_PORT:=80}
: ${CB_API_URL:="http://$CB_API_HOST:$CB_API_PORT"}
: ${CB_UI_ADDR:="http://$CB_API_HOST"}
: ${CB_DB_ENV_USER:=cloudbreak}
: ${CB_DB_ENV_PASS:=cloudbreak}

: ${DOCKER_IMAGE_TAG:=0.1-hotfix}

if [[ "$DOCKER_IMAGE_TAG" != "latest" ]] ; then
  docker pull sequenceiq/uluwatu:$DOCKER_IMAGE_TAG
  docker pull sequenceiq/cloudbreak:$DOCKER_IMAGE_TAG
fi

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

# Removes previous containers
docker inspect cloudbreak &>/dev/null &&  docker rm -f cloudbreak

# Start the CLoudbreak application docker container
docker run -d --name="cloudbreak" \
-e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" \
-e "AWS_SECRET_KEY=$AWS_SECRET_KEY" \
-e "CB_HBM2DDL_STRATEGY=create" \
-e "CB_SMTP_SENDER_USERNAME=$CB_SMTP_SENDER_USERNAME" \
-e "CB_SMTP_SENDER_PASSWORD=$CB_SMTP_SENDER_PASSWORD" \
-e "CB_SMTP_SENDER_HOST=$CB_SMTP_SENDER_HOST" \
-e "CB_SMTP_SENDER_PORT=$CB_SMTP_SENDER_PORT" \
-e "CB_SMTP_SENDER_FROM=$CB_SMTP_SENDER_FROM" \
-e "CB_AZURE_IMAGE_URI=$CB_AZURE_IMAGE_URI" \
-e "CB_BLUEPRINT_DEFAULTS=$CB_BLUEPRINT_DEFAULTS" \
-e "CB_SNS_SSL=$CB_SNS_SSL" \
-e "CB_MANAGEMENT_CONTEXT_PATH=$CB_MANAGEMENT_CONTEXT_PATH" \
-e "CB_UI_ADDR=$CB_UI_ADDR" \
-e "CB_DEFAULT_USER_EMAIL=$CB_DEFAULT_USER_EMAIL" \
-e "CB_DEFAULT_USER_PASSWORD=$CB_DEFAULT_USER_PASSWORD" \
-e "CB_DEFAULT_USER_FIRSTNAME=$CB_DEFAULT_USER_FIRSTNAME" \
-e "CB_DEFAULT_USER_LASTNAME=$CB_DEFAULT_USER_LASTNAME" \
-e "CB_DEFAULT_COMPANY_NAME=$CB_DEFAULT_COMPANY_NAME" \
--link postgresql:cb_db \
-p $CB_API_PORT:8080 \
-p $CB_UI_PORT:80 \
sequenceiq/cloudbreak:$DOCKER_IMAGE_TAG bash

# we are starting the wait_for_cloudbreak_api.sh script in a container
# using the same network interface as cloudbreak, so it can check
# simple on 127.0.0.1 event in a different container
docker run -it --rm \
  --net=container:cloudbreak \
  --entrypoint /bin/bash \
  sequenceiq/cloudbreak:$DOCKER_IMAGE_TAG -c /wait_for_cloudbreak_api.sh


# Removes previous containers
docker inspect uluwatu &>/dev/null && docker rm -f uluwatu

docker run -d --name uluwatu \
  -e CB_API_URL="$CB_API_URL" \
  --net=container:cloudbreak \
  sequenceiq/uluwatu:$DOCKER_IMAGE_TAG

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

if command_exists boot2docker; then
  CLOUDBREAK_IP=$(boot2docker ip 2> /dev/null)
else
  CLOUDBREAK_IP=$(docker inspect -f "{{.NetworkSettings.IPAddress}}" cloudbreak)
fi

cat <<EOF
=============================
= Please put this line into =
= /etc/hosts                =
=============================

$CLOUDBREAK_IP  $CB_API_HOST

EOF
