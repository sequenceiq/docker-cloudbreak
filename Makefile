export MAVEN_METADATA_URL = maven.sequenceiq.com/releases/com/sequenceiq/cloudbreak/maven-metadata.xml
export DOCKER_IMAGE = sequenceiq/cloudbreak

dockerhub:
	./deploy.sh $(VERSION)
