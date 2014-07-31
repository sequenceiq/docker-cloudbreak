#!/bin/bash

clear

# database settings
: ${CB_DB_ENV_USER:?"Please set the \$CB_DB_ENV_USER environment variable! export CB_DB_ENV_USER="}
: ${CB_DB_ENV_PASS:?"Please set the \$CB_DB_ENV_PASS environment variable! "}
: ${CB_HBM2DDL_STRATEGY:="create"}

# SMTP properties
: ${CB_SMTP_SENDER_USERNAME:?"Please set the \$CB_SMTP_SENDER_USERNAME environment variable! export CB_SMTP_SENDER_USERNAME="}
: ${CB_SMTP_SENDER_PASSWORD:?"Please set the \$CB_SMTP_SENDER_PASSWORD environment variable! export CB_SMTP_SENDER_PASSWORD="}
: ${CB_SMTP_SENDER_HOST:?"Please set the \$CB_SMTP_SENDER_HOST environment variable! export CB_SMTP_SENDER_HOST="}
: ${CB_SMTP_SENDER_PORT:?"Please set the \$CB_SMTP_SENDER_PORT environment variable! export CB_SMTP_SENDER_PORT="}
: ${CB_SMTP_SENDER_FROM:?"Please set the \$CB_SMTP_SENDER_FROM environment variable! export CB_SMTP_SENDER_FROM="}

# Azure
: ${CB_AZURE_IMAGE_URI:="http://vmdepoteastus.blob.core.windows.net/linux-community-store/community-62091-a59dcdc1-d82d-4e76-9094-27b8c018a4a1-1.vhd"}

# Ambari
: ${CB_MANAGEMENT_CONTEXT_PATH:="/"}
: ${CB_BLUEPRINT_DEFAULTS:="lambda-architecture,multi-node-hdfs-yarn,single-node-hdfs-yarn"}

# AWS related (optional) settings - not setting them causes AWS related operations to fail
: ${AWS_ACCESS_KEY_ID:?"Please set the \$AWS_ACCESS_KEY_ID environment variable! export AWS_ACCESS_KEY_ID="}
: ${AWS_SECRET_KEY:?"Please set the \$AWS_SECRET_KEY environment variable! export AWS_SECRET_KEY="}

# AWS SNS subscriptions should use HTTPS endpoints or not
: ${CB_SNS_SSL:="false"}

# Cloudbreak User information
: ${CB_USER:?"Please set the \$CB_USER environment variable! export CB_USER="}
: ${CB_PASS:?"Please set the \$CB_PASS environment variable! export CB_PASS="}


echo Starting cloudbreak with the following settings:

for p in "${!CB_@}"; do
  echo $p=${!p}
done
