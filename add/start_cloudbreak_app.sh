#!/bin/bash
# To be used only when no ngrok has to be configured

#: ${CB_HOST_ADDR:=$(hostname -i)}
# export CB_HOST_ADDR="http://$CB_HOST_ADDR:8080"

# Starting ngrok
echo "Starting ngrok ..."
./bin/ngrok -log=stdout 8080 2>&1>/dev/null &

echo "Waiting 10 seconds for ngrok ..."
sleep 10

echo "Getting the ngrok address ..."
CB_HOST_ADDR=$(curl -L http://localhost:4040 | grep -o "http://[0-9a-fA-F]*.ngrok.com")

echo "Ngrok address: $CB_HOST_ADDR"
export CB_HOST_ADDR=$CB_HOST_ADDR

echo "Starting the Cloudbreak application..."
java -jar /cloudbreak.jar
