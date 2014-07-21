#!/bin/bash -e

echo "Setting up cloudbreak infrastructure ..."

# check the environment
. set_env.sh

# Start a postgres database docker container
docker run -d --name="postgresql" -p 5432:5432 -v /tmp/data:/data \
  -e "USER=$CB_DB_ENV_USER" \
  -e "DB=$CB_DB_ENV_DB" \
  -e "PASS=$CB_DB_ENV_PASS"  \
  paintedfox/postgresql

timeout=10
echo "Wait $timeout seconds for the POSTGRES DB to start up"
sleep $timeout

# Start the CLoudbreak application docker container
docker rm -f "cloudbreak" || true

docker run -d --name="cloudbreak" -v /tmp/logs:/logs \
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
-e "CB_SNS_SSL=false" \
-e "CB_MANAGEMENT_CONTEXT_PATH=/" \
--link postgresql:cb_db \
-p 8889:8080 \
sequenceiq/cloudbreak bash

maxAttempts=10
pollTimeout=10
BACKEND_IP=$(docker inspect --format="{{.NetworkSettings.IPAddress}}" $(docker ps -ql))
echo Backend ip: $BACKEND_IP

url=${BACKEND_IP}:8080${CB_MANAGEMENT_CONTEXT_PATH}health
echo URL: $url

timeout=60
echo "Wait $timeout seconds for the CLOUDBREAK APP to start up"
sleep $timeout

# register the user
echo "Registering the user: $CB_USER"
curl -sX POST -H "Content-Type: application/json" http://$BACKEND_IP:8080/users \
  --data "{\"email\": \""$CB_USER"\", \"password\": \""$CB_PASS"\",  \"firstName\": \"seq\", \"lastName\": \"pwd\", \"company\": \"SequenceIQ\" }" | jq '.'


echo "Please check your email and confirm your registation."
