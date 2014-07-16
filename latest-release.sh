#!/bin/bash

: ${JAR_PATH:=/tmp/cloudbreak.jar}

SNAPSHOT_URL=http://seq-repo.s3-website-eu-west-1.amazonaws.com/releases
PACKAGE=com/sequenceiq
ARTIFACT=cloudbreak
FULLNAME=$PACKAGE/$ARTIFACT

VERSION=$(curl -Ls $SNAPSHOT_URL/$FULLNAME/maven-metadata.xml|sed -n "s/.*<version>\([^<]*\).*/\1/p" |tail -1)
echo Version: $VERSION


echo downloading exetuable jar into $JAR_PATH ...
curl -o $JAR_PATH $SNAPSHOT_URL/$FULLNAME/$VERSION/$ARTIFACT-$VERSION.jar

echo To start the Cloudbreak application type:
echo =========================================
echo java -jar $JAR_PATH
echo =========================================
