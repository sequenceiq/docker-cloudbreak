#!/bin/bash

# SMTP properties
: ${CB_SMTP_SENDER_USERNAME:?"Please add the SMTP username. Check the following entry in the env_props.sh file: CB_SMTP_SENDER_USERNAME="}
: ${CB_SMTP_SENDER_PASSWORD:?"Please add the SMTP password. Check the following entry in the env_props.sh file: CB_SMTP_SENDER_PASSWORD="}
: ${CB_SMTP_SENDER_HOST:?"Please add the SMTP host. Check the following entry in the env_props.sh file: CB_SMTP_SENDER_HOST="}
: ${CB_SMTP_SENDER_PORT:?"Please add the SMTP port. Check the following entry in the env_props.sh file: CB_SMTP_SENDER_PORT="}
: ${CB_SMTP_SENDER_FROM:?"Please add the address to appear in the 'From:' field of emails sent by the system: CB_SMTP_SENDER_FROM="}

# AWS related (optional) settings - not setting them causes AWS related operations to fail
: ${AWS_ACCESS_KEY_ID:?"Please set the AWS access key. Check the following entry in the env_props.sh file:AWS_ACCESS_KEY_ID="}
: ${AWS_SECRET_KEY:?"Please set the AWS secret. Check the following entry in the env_props.sh file: AWS_SECRET_KEY="}

echo Starting cloudbreak with the following settings:

for p in "${!CB_@}"; do
  echo $p=${!p}
done
