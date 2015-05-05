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
sed 's/ENV VERSION.*/ENV VERSION 0.5.22/' Dockerfile > Dockerfile.custom
docker build -f Dockerfile.custom --rm -t  sequenceiq/cloudbreak:custom-0.5.22 .
```

## Running the image
It is intended to run only with [Cloudbreak Deployer](https://github.com/sequenceiq/cloudbreak-deployer).
