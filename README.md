
*Cloudbreak is a powerful left surf that breaks over a coral reef, a mile off southwest the island of Tavarua, Fiji.*

*Cloudbreak is a cloud agnostic Hadoop as a Service API. Abstracts the provisioning and ease management and monitoring of on-demand clusters.*

## Overview

Cloudbreak is a RESTful Hadoop as a Service API. Once it is deployed in your favourite servlet container exposes a REST API allowing to span up Hadoop clusters of arbitrary sizes on your selected cloud provider. Provisioning Hadoop has never been easier. Cloudbreak is built on the foundation of cloud providers API (Amazon AWS, Microsoft Azure, Google Cloud Compute...), Apache Ambari, Docker containers, Serf and dnsmasq.

Please note that we are also hosting (based on this Docker image) a Cloudbreak instance - which we maintain, support and continuously improve - based on your feedback. The hosted Cloudbreak is available here:

SequenceIQ's hosted Cloudbreak [instance](https://cloudbreak.sequenceiq.com/).

Cloudbreak [product documentation](http://sequenceiq.com/cloudbreak/).

Cloudbreak [API documentation](http://docs.cloudbreak.apiary.io/).


## Cloudbreak Docker container

We are trying to ease your way to start Cloudbreak and launch on-demand Hadoop clusters in the cloud. The easiest way to start with Cloudbreak is by starting it in  this Docker container. We have put together a fully configured and working Docker container - you will just have to set a few environment variables and you are ready to go.

### Build the image

If you'd like to try directly from the Dockerfile you can build the image as:
```
docker build  -t sequenceiq/cloudbreak .
```

### Start Cloudbreak API

To have a running cloudbreak instance on your machine (made up of docker containers hosting a postgres database, the cloudbreak application and a cloudbreak shell respectively), you can run the script:

```
./start_cloudbreak.sh
```

This will drive you through setting up the required environment variables and starts the configured Cloudbreak application. It also registers a user based on the information provided. At this point you'll havea fully functional CLoudbreak instance running on your host machine; you can start using it by accessing its  REST interface.


### Using Cloudbreak CLI

After the registration confirmation you can start a Cloudbreak shell in a docker container by running the script:

```
./start_cli.sh
```

### Using Cloudbreak UI 

TBD 

### Using Cloudbreak UI - on the host

If you'd like to use the Cloudbreak UI instead of the CLI, you'll need to start the UI application on your host machine (localhost).

To run the UI app from localhost:

* install nginx
* clone the UI project `git clone git@github.com:sequenceiq/uluwatu.git` into the appropriate folder of the nginx (or configure the nginx to use the folder which you cloned the project into)
* set the IP address of the backend for the `connection.properties` property. In order to learn the IP address use: `docker ps -a` to get the running containers (you should see two containers running with the name _sequenceiq/cloudbreak:latest_ and _paintedfox/postgresql:latest_) then use `docker inspect --format="{{.NetworkSettings.IPAddress}}" CONTAINER ID` to return the IP address. `CONTAINER ID` is listed right beside the image name (sequenceiq/cloudbreak:latest).


