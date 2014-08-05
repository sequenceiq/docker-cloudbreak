#!/bin/bash -e
# Cloudbreak User information
source env_props.sh

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
