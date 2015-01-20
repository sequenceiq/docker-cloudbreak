FROM dockerfile/java
MAINTAINER SequenceIQ

# install the cloudbreak app
ADD https://s3-eu-west-1.amazonaws.com/maven.sequenceiq.com/releases/com/sequenceiq/cloudbreak/0.3.17/cloudbreak-0.3.17.jar /cloudbreak.jar

# install the cloudbreak-shell app
ADD https://s3-eu-west-1.amazonaws.com/maven.sequenceiq.com/releases/com/sequenceiq/cloudbreak-shell/0.2.25/cloudbreak-shell-0.2.25.jar /cloudbreak-shell.jar

# Install starter script for the Cloudbreak application
ADD add/start_cloudbreak_app.sh /
ADD add/wait_for_cloudbreak_api.sh /

# Install starter script for the cloudbreak shell application
ADD add/start_cloudbreak_shell_app.sh /

# add ngrok
ADD add/ngrok.zip /ngrok.zip

# Install zip
RUN apt-get update
RUN apt-get install zip

RUN sudo unzip /ngrok -d /bin

WORKDIR /

ENTRYPOINT ["/start_cloudbreak_app.sh"]
