#!/bin/bash
: <<USAGE
========================================================
this script is intended to be run in a docker container
========================================================

docker run -it --rm \
  -v /usr/local/bin/docker:/usr/local/bin/docker \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --entrypoint /bin/bash \
  sequenceiq/cloudbreak -c /wait_for_cloudbreak_api.sh

USAGE

#pollTimeout=10

CLOUDBREAK_IP=$(docker inspect -f "{{.NetworkSettings.IPAddress}}" cloudbreak)

if [ $? -ne 0 ]; then
  echo [ERROR] no docker container named 'cloudbreak' is running
  exit -1
fi

url="http://$CLOUDBREAK_IP:8080/health"
maxAttempts=10
pollTimeout=30

cat <<EOF
========================================================
= echo this container waits for cloudbreak availabilty =
= by checking the health url:
=   $url
=
= maxAttempts=$maxAttempts
========================================================
EOF

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
