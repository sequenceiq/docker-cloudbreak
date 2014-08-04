#!/bin/bash

echo "Setting up cloudbreak infrastructure ..."

# check the environment
source env_props.sh
./check_env.sh

#while [ $? -eq 1 ]
#do
#  read value
#  echo "export $value"
#  export "$value"
#  ./set_env.sh
#done


if [ $? -ne 0 ];
  then
  exit 1;
fi

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
-p 8080:8080 \
sequenceiq/cloudbreak bash

#pollTimeout=10
BACKEND_IP=$(docker inspect --format="{{.NetworkSettings.IPAddress}}" $(docker ps -ql))
echo Backend ip: $BACKEND_IP


url="http://$BACKEND_IP:8080/health"
maxAttempts=10
pollTimeout=30

for (( i=1; i<=$maxAttempts; i++ ))
do
    echo "GET $url. Attempt #$i"
    code=`curl -sL -w "%{http_code}\\n" "$url" -o /dev/null`
    echo "Found code $code"
    if [ "x$code" = "x200" ]
    then
         echo "SequenceIQ Cloudbreak is available!"
         break
    elif [ $i -eq $maxAttempts ]
    then
         echo "SequenceIQ Cloudbreak not started in time."
         exit 1
    fi
    sleep $pollTimeout
done

# register the user
echo "Registering the user: $CB_USER"

curl -sX POST -H "Content-Type: application/json" "http://${BACKEND_IP}:8080/users" \
  --data "{\"email\": \""$CB_USER"\", \"password\": \""$CB_PASS"\",  \"firstName\": \"seq\", \"lastName\": \"pwd\", \"company\": \"Testing ltd\", \"userType\":\"DEFAULT\" }" | jq '.'

echo "Please check your emails and confirm your registation."
