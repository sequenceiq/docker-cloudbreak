#!/bin/bash

[[ "$TRACE" ]] && set -x

: ${DEBUG:=1}

debug() {
    [[ "$DEBUG" ]] && echo "[DEBUG] $*" 1>&2
}

BRIDGE_IP=$(docker run --rm gliderlabs/alpine:3.1 ip ro | grep default | cut -d" " -f 3)

con() {
  declare path="$1"
  shift
  local consul_ip=$(dig @${BRIDGE_IP} +short consul-8500.service.consul)
  curl ${consul_ip}:8500/v1/${path} "$@"
}

serv(){
  [ $# -gt 0 ] && path=service/$1 || path=services
  con catalog/$path -s |jq .
}

# dig service host ip
dh() {
  dig @${BRIDGE_IP} +short $1.service.consul
}

# dig service port
dp() {
  dig @${BRIDGE_IP} +short $1.service.consul SRV | cut -d" " -f 3
}

# dig host:port
dhp(){
    echo $(dh $1):$(dp $1)
}

start_consul() {
    declare desc="starts consul binding to: $BRIDGE_IP http:8500 dns:53 rpc:8400"

    debug $desc
    docker run -d \
        -h node1 \
        --name=consul \
        -p ${BRIDGE_IP}:53:53/udp \
        -p ${BRIDGE_IP}:8400:8400 \
        -p ${BRIDGE_IP}:8500:8500 \
        sequenceiq/consul:v0.5.0 -server -bootstrap -advertise ${BRIDGE_IP}
}

start_registrator() {
    declare desc="starts registrator connecting to consul"

    debug $desc
    docker run -d \
      --name=registrator \
      -v /var/run/docker.sock:/tmp/docker.sock \
      gliderlabs/registrator:v5 consul://${BRIDGE_IP}:8500
}

start_cloudbreak_db() {
    declare desc="starts postgress container for cloudbreak backend"

    debug $desc
    docker run -d -P \
      --name=postgresql \
      -e "SERVICE_NAME=cbdb" \
      -v /var/lib/cloudbreak/cbdb:/var/lib/postgresql/data \
      postgres:9.4.0

    sleep 10
    
    docker run -it --rm \
      --link postgresql:postgres \
      postgres:9.4.0 sh -c 'exec createdb -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres cloudbreak'

    docker run -it --rm \
      --link postgresql:postgres \
      postgres:9.4.0 sh -c 'exec dropdb -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres postgres'
}

start_uaa() {
    declare desc="starts the uaa based OAuth identity server with psql backend"

    debug $desc
    docker run -d -P \
      --name="uaadb" \
      -e "SERVICE_NAME=uaadb" \
      -v /var/lib/cloudbreak/uaadb:/var/lib/postgresql/data \
      postgres:9.4.0
    
    debug "waits for uaadb get registered in consul"
    sleep 5
    debug "uaa db: $(dhp uaadb) "

    #  -v /usr/local/cloudbreak/uaa.yml:/uaa/uaa.yml \
    docker run -d -P \
      --name="uaa" \
      -e IDENTITY_DB_URL=$(dhp uaadb) \
      -v $PWD/uaa.yml:/uaa/uaa.yml \
      sequenceiq/uaa:1.8.1-v1
}

start_cloudbreak_shell() {
    declare desc="starts cloudbreak shell"

    debug $desc
    docker run -it \
        -e SEQUENCEIQ_USER=admin@sequenceiq.com\
        -e SEQUENCEIQ_PASSWORD=seqadmin \
        -e IDENTITY_ADDRESS=http://$(dhp uaa) \
        -e CLOUDBREAK_ADDRESS=http://$(dhp cloudbreak) \
        sequenceiq/cb-shell:0.2.38
}

cb_envs_to_docker_options() {
  declare desc="create -e var=value options for docker run with all CB_XXX env variables"

  DOCKER_CB_ENVS=""
  for var in  ${!CB_*}; do
    DOCKER_CB_ENVS="$DOCKER_CB_ENVS -e $var=${!var}"
  done
}

start_cloudbreak() {
    declare desc="starts cloudbreak component"

    debug $des
    cb_envs_to_docker_options
  
    set -x
    docker run -d \
        --name=cloudbreak \
        -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
        -e AWS_SECRET_KEY=$AWS_SECRET_KEY \
        -e CB_IDENTITY_SERVER_URL=http://$(dhp uaa) \
        $DOCKER_CB_ENVS \
        --link postgresql:cb_db \
        -p 8080 \
        sequenceiq/cloudbreak:$CB_DOCKER_IMAGE_TAG bash
    set +x
}

start_uluwatu() {
    docker run -d --name uluwatu \
    -e ULU_PRODUCTION=true \
    -e ULU_NEW_RELIC_KEY=f41e039f20ed06106eecbe9017c85d86969cb57e \
    -e ULU_NEW_RELIC_APP=uluwatuprod \
    -e ULU_CLOUDBREAK_ADDRESS=http://$(dhp cloudbreak) \
    -e ULU_OAUTH_REDIRECT_URI=http://104.154.86.68:3000/authorize \
    -e ULU_IDENTITY_ADDRESS=http://104.154.86.68:49162/ \
    -e ULU_SULTANS_ADDRESS=http://104.154.86.68:49162/  \
    -e ULU_OAUTH_CLIENT_ID=uluwatu-dev \
    -e ULU_OAUTH_CLIENT_SECRET=f2b9f54c-e8e4-4da7-b5ce-276db040ed6c \
    -e ULU_HOST_ADDRESS=http://104.154.86.68:3000 \
    -e ULU_ZIP=v0.1.398 \
    -e NODE_TLS_REJECT_UNAUTHORIZED=0 \
    -e ULU_PERISCOPE_ADDRESS=http://akjshdakjhdakd.kom:8080 \
    -p 3000:3000 sequenceiq/uluwatu
}

token() {
    export TOKEN=$(curl -siX POST \
        -H "accept: application/x-www-form-urlencoded" \
        -d 'credentials={"username":"admin@sequenceiq.com","password":"seqadmin"}' \
        "$(dhp uaa)/oauth/authorize?response_type=token&client_id=cloudbreak_shell&scope.0=openid&source=login&redirect_uri=http://cloudbreak.shell" \
          | grep Location | cut -d'=' -f 2 | cut -d'&' -f 1)
}

# dig short
digs() {
    dig @${BRIDGE_IP} +short +search
}

xxx() {
    curl $(dig @${BRIDGE_IP} +short consul-8500.service.consul):8500/v1/
}

bridge_osx() {
    BRIDGE_IP=$(docker run --rm mini/base ip ro | grep default | cut -d" " -f 3)
    sudo networksetup -setdnsservers Wi-Fi 192.168.1.1 $BRIDGE_IP 8.8.8.8
    sudo networksetup -setsearchdomains Wi-Fi service.consul node.consul
}

main() {
  start_consul
  start_registrator
  start_uaa
  start_cloudbreak_db
  start_cloudbreak
}

[[ "$BASH_SOURCE" == "$0" ]] && main "$@"
