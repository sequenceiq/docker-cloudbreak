#!/bin/bash -e
set +x


# Start a postgres database docker container
docker run -d --name="postgresql" -p 5432:5432 -v /tmp/data:/data \
  -e "USER="$CB_DB_ENV_USER" \
  -e "DB=$CB_DB_ENV_DB_NAME" \
  -e "PASS=$CB_DB_ENV_PASS"  \
  paintedfox/postgresql

# Start the CLoudbreak application docker container
docker rm -f cloudbreak-api || true
docker run -d --name cloudbreak-api \
 -v $WORKSPACE/logs:/tmp/logs:rw \
 docker run -d --name cloudbreak \
-e "VERSION=$VERSION" \
-e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" \
-e "AWS_SECRET_KEY=$AWS_SECRET_KEY" \
-e "CB_HBM2DDL_STRATEGY=create" \
-e "CB_SMTP_SENDER_USERNAME=$MAIL_SENDER_USERNAME" \
-e "CB_SMTP_SENDER_PASSWORD=$MAIL_SENDER_PASSWORD" \
-e "CB_SMTP_SENDER_HOST=$MAIL_SENDER_HOST" \
-e "CB_SMTP_SENDER_PORT=$MAIL_SENDER_PORT" \
-e "CB_SMTP_SENDER_FROM=$MAIL_SENDER_FROM" \
-e "CB_HOST_ADDR=$HOST_ADDR" \
-e "CB_AZURE_IMAGE_URI=$AZURE_IMAGE_URI" \
-e "CB_BLUEPRINT_DEFAULTS=$BLUEPRINT_DEFAULTS" \
-e "CB_SNS_SSL=false"
--link postgresql:cb_db \
-p 8889:8080 \
sequenceiq/cloudbreak bash

timeout=20
echo "Wait $timeout seconds for the CLOUDBREAK API to start up"
sleep $timeout
