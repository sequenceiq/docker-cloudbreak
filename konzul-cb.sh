#!/bin/bash

[[ "$TRACE" ]] && set -x

: ${DEBUG:=1}
: ${HOST_ADDRESS:=http://localhost}

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


set_env_props() {
    export CB_BLUEPRINT_DEFAULTS="lambda-architecture,multi-node-hdfs-yarn,hdp-multinode-default"

    # oauth config for cloudbreak: must match 'id' and 'secret' attributes at
    # oauth/clients/cloudbreak section in uaa.yml
    # TODO : check if uaa.yml can take these attrs dynamically from env vars via special ${} anotation
    export CB_CLIENT_ID="cloudbreak"
    export CB_CLIENT_SECRET="cloudbreaksecret"

    # define base images for each provider
    export CB_AZURE_IMAGE_URI="https://102589fae040d8westeurope.blob.core.windows.net/images/packer-cloudbreak-2015-02-17_2015-February-17_14-27-os-2015-02-17.vhd"
    export CB_GCP_SOURCE_IMAGE_PATH="sequenceiqimage/sequenceiq-ambari17-consul-2015-02-17-1439.image.tar.gz"
    export CB_AWS_AMI_MAP="ap-northeast-1:ami-7535d475,ap-southeast-2:ami-c33b4df9,sa-east-1:ami-d1bc02cc,ap-southeast-1:ami-4a340018,eu-west-1:ami-4d9f0a3a,us-west-1:ami-f6c8d2b3,us-west-2:ami-a92f0899,us-east-1:ami-728ade1a"
    export CB_OPENSTACK_IMAGE="ubuntu1404_cloudbreak-v1-recipe"

    # cloudbreak DB config
    #export CB_DB_ENV_USER="cloudbreak"
    #export CB_DB_ENV_USER="postgres"
    #export CB_DB_ENV_DB="cloudbreak"
    #export CB_DB_ENV_PASS=
    export CB_HBM2DDL_STRATEGY="create"
    export PERISCOPE_DB_HBM2DDL_STRATEGY="create"


    if [ ! -f env_props.sh ] ;then
      cp env_props.sh.sample env_props.sh
      cat <<EOF
=================================================
= Please fill missing variables in:env_props.sh =
=================================================
EOF
      exit
    fi

}

check_env_props() {
    source env_props.sh
    source check_env.sh
    if [ $? -ne 0 ]; then
      exit 1;
    fi
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
        -v /var/run/docker.sock:/var/run/docker.sock \
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

wait_for_service() {
    declare desc="waits for a service entry to appear in consul"
    declare service=$1
    : ${service:? required}

    ( docker run -it --rm \
        --net container:consul \
        --entrypoint /bin/consul \
        sequenceiq/consul:v0.5.0 \
          watch -type=service -service=$service bash -c 'cat|grep "\[\]" '
    ) &> /dev/null
}

start_cloudbreak_db() {
    declare desc="starts postgress container for cloudbreak backend"
    debug $desc
    docker run -d -P \
      --name=cbdb \
      -e "SERVICE_NAME=cbdb" \
      -v /var/lib/cloudbreak/cbdb:/var/lib/postgresql/data \
      postgres:9.4.0

    wait_for_service cbdb
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
    wait_for_service uaadb
    debug "uaa db: $(dhp uaadb) "

    docker run -d -P \
      --name="uaa" \
      -e "SERVICE_NAME=uaa" \
      -e IDENTITY_DB_URL=$(dhp uaadb) \
      -v $PWD/uaa.yml:/uaa/uaa.yml \
      -v /var/lib/uaa/uaadb:/var/lib/postgresql/data \
      -p 8089:8080 \
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

wait_for_service() {
    declare desc="waits for a service entry to appear in consul"
    declare service=$1
    : ${service:? required}

    ( docker run -it --rm \
        --net container:consul \
        --entrypoint /bin/consul \
        sequenceiq/consul:v0.5.0 \
          watch -type=service -service=$service bash -c 'cat|grep "\[\]" '
    ) &> /dev/null
}

start_cloudbreak() {
    declare desc="starts cloudbreak component"

    debug $desc
    wait_for_service cbdb
    debug "cloudbreak db: $(dhp cbdb)"
    export CB_HOST_ADDR=$HOST_ADDRESS
    cb_envs_to_docker_options

    docker run -d \
        --name=cloudbreak \
        -e "SERVICE_NAME=cloudbreak" \
        -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
        -e AWS_SECRET_KEY=$AWS_SECRET_KEY \
        -e SERVICE_NAME=cloudbreak \
        -e CB_IDENTITY_SERVER_URL=http://$(dhp uaa) \
        -e CB_DB_PORT_5432_TCP_ADDR=$(dh cbdb) \
        -e CB_DB_PORT_5432_TCP_PORT=$(dp cbdb) \
        $DOCKER_CB_ENVS \
        -p 8080:8080 \
        sequenceiq/cloudbreak:0.3.65 bash
}

start_uluwatu() {
    docker run -d --name uluwatu \
    -e ULU_PRODUCTION=false \
    -e SERVICE_NAME=uluwatu \
    -e ULU_CLOUDBREAK_ADDRESS=http://$(dhp cloudbreak) \
    -e ULU_OAUTH_REDIRECT_URI=$HOST_ADDRESS:3000/authorize \
    -e ULU_IDENTITY_ADDRESS=http://$(dhp uaa)/ \
    -e ULU_SULTANS_ADDRESS=$HOST_ADDRESS:3001 \
    -e ULU_OAUTH_CLIENT_ID=uluwatu \
    -e ULU_OAUTH_CLIENT_SECRET=1AABF87E-EA02-414D-A7C3-72B66D1D8392 \
    -e ULU_HOST_ADDRESS=$HOST_ADDRESS:3000 \
    -e ULU_ZIP=v0.1.398 \
    -e NODE_TLS_REJECT_UNAUTHORIZED=0 \
    -e ULU_PERISCOPE_ADDRESS=http://$(dhp periscope)/ \
    -p 3000:3000 sequenceiq/uluwatu
}

start_sultans() {
    docker run -d --name sultans \
    -e SL_CLIENT_ID=sultans \
    -e SL_CLIENT_SECRET=855F78BF-188F-45D1-96DA-A55CE0DAF85B \
    -e SERVICE_NAME=sultans \
    -e SL_PORT=3000 \
    -e SL_UAA_ADDRESS=http://$(dhp uaa) \
    -e SL_SMTP_SENDER_HOST=$CB_SMTP_SENDER_HOST \
    -e SL_SMTP_SENDER_PORT=$CB_SMTP_SENDER_PORT \
    -e SL_SMTP_SENDER_USERNAME=$CB_SMTP_SENDER_USERNAME \
    -e SL_SMTP_SENDER_PASSWORD=$CB_SMTP_SENDER_PASSWORD \
    -e SL_SMTP_SENDER_FROM=$CB_SMTP_SENDER_FROM \
    -e SL_CB_ADDRESS=$HOST_ADDRESS:3000 \
    -e SL_ADDRESS=$HOST_ADDRESS:3001 \
    -e SL_ZIP=master \
    -p 3001:3000 sequenceiq/sultans:latest
}

start_periscope_db() {
    declare desc="starts postgress container for cloudbreak backend"
    debug $desc
    docker run -d -P \
      --name=periscopedb \
      -e "SERVICE_NAME=periscopedb" \
      -v /var/lib/periscope/periscopedb:/var/lib/postgresql/data \
      postgres:9.4.0

    debug "waits for periscopedb get registered in consul"
    wait_for_service periscopedb
    debug "periscope db: $(dhp periscopedb) "
}

start_periscope() {
    docker run -d --name=periscope \
    -e PERISCOPE_DB_HBM2DDL_STRATEGY=$PERISCOPE_DB_HBM2DDL_STRATEGY \
    -e PERISCOPE_DB_TCP_PORT=$(dp periscopedb) \
    -e SERVICE_NAME=periscope \
    -e PERISCOPE_DB_TCP_ADDR=$(dh periscopedb) \
    -e PERISCOPE_SMTP_HOST=$CB_SMTP_SENDER_HOST \
    -e PERISCOPE_SMTP_USERNAME=$CB_SMTP_SENDER_USERNAME \
    -e PERISCOPE_SMTP_PASSWORD=$CB_SMTP_SENDER_PASSWORD \
    -e PERISCOPE_SMTP_FROM=$CB_SMTP_SENDER_FROM \
    -e PERISCOPE_SMTP_PORT=$CB_SMTP_SENDER_PORT \
    -e PERISCOPE_CLOUDBREAK_URL=http://$(dhp cloudbreak) \
    -e PERISCOPE_IDENTITY_SERVER_URL=http://$(dhp uaa)/ \
    -e PERISCOPE_CLIENT_ID=periscope \
    -e PERISCOPE_CLIENT_SECRET=C86B319D-2ED6-48C7-BDA0-D1E47636F9B6 \
    -e PERISCOPE_HOSTNAME_RESOLUTION=public \
    -e ENDPOINTS_AUTOCONFIG_ENABLED=false \
    -e ENDPOINTS_DUMP_ENABLED=false \
    -e ENDPOINTS_TRACE_ENABLED=false \
    -e ENDPOINTS_CONFIGPROPS_ENABLED=false \
    -e ENDPOINTS_METRICS_ENABLED=false \
    -e ENDPOINTS_MAPPINGS_ENABLED=false \
    -e ENDPOINTS_BEANS_ENABLED=false \
    -e ENDPOINTS_ENV_ENABLED=false \
    -p 8085:8080 \
    sequenceiq/periscope:latest
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
  set_env_props
  check_env_props
  start_consul
  start_registrator
  start_uaa
  start_cloudbreak_db
  start_cloudbreak
  start_periscope_db
  start_periscope
  start_sultans
  start_uluwatu
}

[[ "$BASH_SOURCE" == "$0" ]] && main "$@"
