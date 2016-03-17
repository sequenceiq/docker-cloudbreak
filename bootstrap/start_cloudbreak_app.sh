#!/bin/bash

: ${SECURE_RANDOM:=true}
: ${TRUSTED_CERT_DIR:=/certs/trusted}

echo "Importing certificates to the default Java certificate  trust store."

if [ -d "$TRUSTED_CERT_DIR" ]; then
    for cert in $(ls -A "$TRUSTED_CERT_DIR"); do
        if [ -f "$TRUSTED_CERT_DIR/$cert" ]; then
            if keytool -import -alias "$cert" -noprompt -file "$TRUSTED_CERT_DIR/$cert" -keystore /etc/ssl/certs/java/cacerts -storepass changeit; then
                echo -e "Certificate added to default Java trust store with alias $cert."
            else
                echo -e "WARNING: Failed to add $cert to trust store.\n"
            fi
        fi
    done
fi

echo "Starting the Cloudbreak application..."

set -x
if [ "$SECURE_RANDOM" == "false" ]; then
  CB_JAVA_OPTS="$CB_JAVA_OPTS -Djava.security.egd=file:/dev/./urandom"
fi

java $CB_JAVA_OPTS -jar /cloudbreak.jar
