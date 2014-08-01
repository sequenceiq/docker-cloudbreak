#!/bin/bash

# clear

# database settings
: ${CB_DB_ENV_USER:?"Please set the database user. Check the following entry in the env_props.sh file:CB_DB_ENV_USER="}
: ${CB_DB_ENV_PASS:?"Please set the database password. Check the following entry in the env_props.sh file:CB_DB_ENV_PASS="}
: ${CB_HBM2DDL_STRATEGY:="create"}

# SMTP properties
: ${CB_SMTP_SENDER_USERNAME:?"Please add the SMTP username. Check the following entry in the env_props.sh file:CB_SMTP_SENDER_USERNAME="}
: ${CB_SMTP_SENDER_PASSWORD:?"Please add the SMTP password. Check the following entry in the env_props.sh file:CB_SMTP_SENDER_PASSWORD="}
: ${CB_SMTP_SENDER_HOST:?"Please add the SMTP host. Check the following entry in the env_props.sh file:CB_SMTP_SENDER_HOST="}
: ${CB_SMTP_SENDER_PORT:?"Please add the SMTP port. Check the following entry in the env_props.sh file:CB_SMTP_SENDER_PORT="}
: ${CB_SMTP_SENDER_FROM:?"Please add the address to appear in the 'From:' field of emails sent by the system: CB_SMTP_SENDER_FROM="}

# Azure
: ${CB_AZURE_IMAGE_URI:="http://vmdepoteastus.blob.core.windows.net/linux-community-store/community-62091-a59dcdc1-d82d-4e76-9094-27b8c018a4a1-1.vhd"}

# Ambari
: ${CB_MANAGEMENT_CONTEXT_PATH:="/"}
: ${CB_BLUEPRINT_DEFAULTS:="lambda-architecture,multi-node-hdfs-yarn,single-node-hdfs-yarn"}

# AWS related (optional) settings - not setting them causes AWS related operations to fail
: ${AWS_ACCESS_KEY_ID:?"Please set the AWS access key. Check the following entry in the env_props.sh file:AWS_ACCESS_KEY_ID="}
: ${AWS_SECRET_KEY:?"Please set the AWS secret. Check the following entry in the env_props.sh file:AWS_SECRET_KEY="}

# AWS SNS subscriptions should use HTTPS endpoints or not
: ${CB_SNS_SSL:="false"}

# Cloudbreak User information
: ${CB_USER:?"Please add the desired Cloudbreak username (email). Check the following entry in the env_props.sh file:CB_USER="}
: ${CB_PASS:?"Please add the desired Cloudbreak password. Check the following entry in the env_props.sh file:  CB_PASS="}

echo Starting cloudbreak with the following settings:

for p in "${!CB_@}"; do
  echo $p=${!p}
done
