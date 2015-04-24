FROM java
MAINTAINER SequenceIQ

ENV VERSION 0.5.18
# install the cloudbreak app
ADD https://s3-eu-west-1.amazonaws.com/maven.sequenceiq.com/releases/com/sequenceiq/cloudbreak/$VERSION/cloudbreak-$VERSION.jar /cloudbreak.jar

# Install starter script for the Cloudbreak application
ADD add/start_cloudbreak_app.sh /
ADD add/wait_for_cloudbreak_api.sh /

# add ngrok
ADD add/ngrok.zip /ngrok.zip

# Install zip
RUN apt-get update
RUN apt-get install zip

RUN unzip /ngrok -d /bin

# extract schema files
RUN unzip cloudbreak.jar schema/* -d /

WORKDIR /

ENTRYPOINT ["/start_cloudbreak_app.sh"]
