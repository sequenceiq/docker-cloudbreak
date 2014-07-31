#!/bin/bash -e
# Cloudbreak User information
: ${CB_USER:?"Please set the \$CB_USER environment variable! export CB_USER="}
: ${CB_PASS:?"Please set the \$CB_PASS environment variable! export CB_PASS="}

for p in "${!CB_@}"; do
  echo $p=${!p}
done


echo Starting the CLI container ...
docker run -it --rm --name="cloudbreak-shell" \
-e CB_USER="$CB_USER" \
-e CB_PASS="$CB_PASS" \
-v /tmp:/tmp \
--link cloudbreak:cb \
--entrypoint /bin/bash \
sequenceiq/cloudbreak -c 'sh /start_cloudbreak_shell_app.sh'

echo Starting cloudbreak with the following settings:
