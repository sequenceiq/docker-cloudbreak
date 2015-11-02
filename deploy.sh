: ${DOCKERHUB_USERNAME:?"required!"}
: ${DOCKERHUB_PASSWORD:?"required!"}

install_deps() {
  if ! dockerhub-tag --version &>/dev/null ;then
    echo "---> installing dockerhub-tag binary to /usr/local/bin" 1>&2
    curl -L https://github.com/progrium/dockerhub-tag/releases/download/v0.2.0/dockerhub-tag_0.2.0_Darwin_x86_64.tgz | tar -xz -C /usr/local/bin/
  else
    echo "---> dockerhub-tag already installed" 1>&2
  fi
}

new_version() {
  install_deps
  declare NEW_VERSION=${1:? version required}

  sed -i "/^ENV VERSION/ s/VERSION .*/VERSION ${NEW_VERSION}/" Dockerfile

  git commit -m "Release ${NEW_VERSION}" Dockerfile
  git tag ${NEW_VERSION}
  git push origin master --tags
  
  dockerhub-tag set sequenceiq/cloudbreak $NEW_VERSION $NEW_VERSION /
}

main() {
  new_version "$@"
}

[[ "$0" ==  "$BASH_SOURCE" ]] && main "$@"
