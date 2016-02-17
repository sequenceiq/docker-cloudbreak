#!/bin/bash

set -eo pipefail
if [[ "$TRACE" ]]; then
    : ${START_TIME:=$(date +%s)}
    export START_TIME
    export PS4='+ [TRACE $BASH_SOURCE:$LINENO][ellapsed: $(( $(date +%s) -  $START_TIME ))] '
    set -x
fi

debug() {
  [[ "$DEBUG" ]] && echo "-----> $*" 1>&2 || :
}


install_deps() {
  if ! dockerhub-tag --version &>/dev/null ;then
    debug "installing dockerhub-tag binary to /usr/local/bin"
    curl -L https://github.com/progrium/dockerhub-tag/releases/download/v0.2.0/dockerhub-tag_0.2.0_$(uname)_x86_64.tgz | tar -xz -C /usr/local/bin/
  else
    debug "dockerhub-tag already installed"
fi
}

get_latest_maven_version() {
  curl -sL ${MAVEN_METADATA_URL} | sed -n '/<version>/ h; $ {x;s/ *<.\?version>//gp;}'
}

new_version() {
  install_deps
  declare NEW_VERSION=${1:-$(get_latest_maven_version)}

  debug "building docker image for version: $NEW_VERSION"

  sed -i "/^ENV VERSION/ s/VERSION .*/VERSION ${NEW_VERSION}/" Dockerfile

  git commit -m "Release ${NEW_VERSION}" Dockerfile
  git tag ${NEW_VERSION}
  git push origin master --tags
  
  dockerhub-tag set ${DOCKER_IMAGE} $NEW_VERSION $NEW_VERSION /
}

main() {
  : ${MAVEN_METADATA_URL:?"required!"}
  : ${DOCKER_IMAGE:?"required!"}
  : ${DOCKERHUB_USERNAME:?"required!"}
  : ${DOCKERHUB_PASSWORD:?"required!"}
  : ${DEBUG:=1}

  new_version "$@"
}

[[ "$0" ==  "$BASH_SOURCE" ]] && main "$@"
