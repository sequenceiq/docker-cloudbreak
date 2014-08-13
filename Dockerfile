FROM dockerfile/java
MAINTAINER SequenceIQ

# install the cloudbreak app
ADD https://s3-eu-west-1.amazonaws.com/seq-repo/releases/com/sequenceiq/cloudbreak/0.1-20140813161039/cloudbreak-0.1-20140813161039.jar /cloudbreak.jar

# install the cloudbreak-shell app
ADD https://s3-eu-west-1.amazonaws.com/maven.sequenceiq.com/snapshots/com/sequenceiq/cloudbreak/cloudbreak-shell/0.1-SNAPSHOT/cloudbreak-shell-0.1-20140813.082015-59.jar /cloudbreak-shell.jar

# Install starter script for the Cloudbreak application
ADD add/start_cloudbreak_app.sh /

# Install starter script for the cloudbreak shell application
ADD add/start_cloudbreak_shell_app.sh /

# add ngrok
ADD add/ngrok.zip /ngrok.zip

# Install zip
RUN apt-get install zip

RUN sudo unzip /ngrok -d /bin

WORKDIR /

ENTRYPOINT ["/start_cloudbreak_app.sh"]
