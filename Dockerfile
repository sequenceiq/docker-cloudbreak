FROM dockerfile/java
MAINTAINER SequenceIQ

ADD latest-release.sh /tmp/

# get the latest release from the maven repo
RUN sh /tmp/latest-release.sh

WORKDIR /tmp
ENTRYPOINT ["java", "-jar", "cloudbreak.jar"]
