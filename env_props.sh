#!/bin/bash

# Azure
export CB_AZURE_IMAGE_URI="http://vmdepoteastus.blob.core.windows.net/linux-community-store/community-62091-a59dcdc1-d82d-4e76-9094-27b8c018a4a1-1.vhd"

export CB_MANAGEMENT_CONTEXT_PATH="/"

export CB_BLUEPRINT_DEFAULTS="lambda-architecture,multi-node-hdfs-yarn,single-node-hdfs-yarn"

export CB_SNS_SSL="false"

export CB_DB_ENV_DB="cloudbreak"

export CB_HBM2DDL_STRATEGY="update"

export CB_UI_ADDR="http://localhost:8081"

# The desired database user name
export CB_DB_ENV_USER=

# The database password
export CB_DB_ENV_PASS=

# SMTP settings
# The username to the used SMTP server
export CB_SMTP_SENDER_USERNAME=

# The password to the used SMTP server
export CB_SMTP_SENDER_PASSWORD=

# THe SMTP server host
export CB_SMTP_SENDER_HOST=

# THe SMTP server port
export CB_SMTP_SENDER_PORT=

# The value of the from field in emails sent by the system (registration, password reset ...)
export CB_SMTP_SENDER_FROM=

# AWS related (optional) settings - not setting them causes AWS related operations to fail
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_KEY=

# Cloudbreak User information
# The username of the cloudbreak user (should be a valid email address!)
export CB_USER=

# The password to access the cloudbreak
export CB_PASS=
