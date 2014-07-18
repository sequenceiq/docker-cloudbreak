#!/bin/bash -e

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
-e "CB_HOST_ADDR=$CB_HOST_ADDR" \
-e "CB_AZURE_IMAGE_URI=$CB_AZURE_IMAGE_URI" \
-e "CB_BLUEPRINT_DEFAULTS=$CB_BLUEPRINT_DEFAULTS" \
-e "CB_SNS_SSL=false" \
-e "CB_MANAGEMENT_CONTEXT_PATH=/" \
--link postgresql:cb_db \
-p 8889:8080 \
sequenceiq/cloudbreak bash

timeout=60
echo "Wait $timeout seconds for the CLOUDBREAK APP to start up"
sleep $timeout

echo Starting the CLI container ...
docker run -it --rm --name="cloudbreak-shell" \
-e CB_USER="$CB_USER" \
-e CB_PASS="$CB_PASS" \
--link cloudbreak:cb \
--entrypoint /bin/bash \
sequenceiq/cloudbreak -c 'sh /start_cb_shell.sh'
