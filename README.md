
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
### Pull the image

The image is also released as an official Docker image from Docker's automated build repository - you can always pull or refer the image when launching containers.

```
docker pull sequenceiq/cloudbreak:0.1
```

### Start the cloudbreak Application

To have a running cloudbreak instance on your machine (made up of docker containers hosting a postgres database, the cloudbreak application and a cloudbreak shell respectively), you can run the script:

```
./start_cloudbreak.sh
```

This will drive you through setting up the required environment variables and starts the configured cloudbreak application. It also registers a user based on the information provided. At this point you'll havea fully functional CLoudbreak instance running on your host machine; you can start using it by accessing its  REST interface.
However after the registration confirmation you can start a cloudbreak shell in a docker container by running the script:

```
start_cli.sh
```
