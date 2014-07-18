FROM dockerfile/java
MAINTAINER SequenceIQ

# install the cloudbreak app
ADD http://seq-repo.s3-website-eu-west-1.amazonaws.com/releases/com/sequenceiq/cloudbreak/0.1-20140717051917/cloudbreak-0.1-20140717051917.jar /cloudbreak.jar

# install the cloudbreak-shell app
ADD https://s3-eu-west-1.amazonaws.com/maven.sequenceiq.com/snapshots/com/sequenceiq/cloudbreak/cloudbreak-shell/0.1-SNAPSHOT/cloudbreak-shell-0.1-20140718.073413-29.jar /cloudbreak-shell.jar

# Install starter script for the cloudbreak shell application
ADD start_cb_shell.sh /

WORKDIR /tmp
ENTRYPOINT ["java", "-jar", "/cloudbreak.jar"]
