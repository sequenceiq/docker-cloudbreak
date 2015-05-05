Cloudbreak on Docker
==========

This repository contains a Docker file to build a Docker image containing Cloudbreak binary and DB schema scripts.
The Cloudbreak source code is available on GitHuv [GitHub](https://github.com/sequenceiq/cloudbreak).

##Pull the image from Docker Repository
```
docker pull sequenceiq/cloudbreak:0.5.20
```

## Building the image
```
docker build --rm -t sequenceiq/cloudbreak:0.5.20 .
```

## Building custom version
```
docker build --rm -t sequenceiq/cloudbreak:0.5.20 .
```

## Running the image
It is intended to run only with [Cloudbreak Deployer](https://github.com/sequenceiq/cloudbreak-deployer).
