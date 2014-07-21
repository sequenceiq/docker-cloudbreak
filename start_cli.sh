#!/bin/bash -e

echo Starting the CLI container ...
docker run -it --rm --name="cloudbreak-shell" \
-e CB_USER="$CB_USER" \
-e CB_PASS="$CB_PASS" \
--link cloudbreak:cb \
--entrypoint /bin/bash \
sequenceiq/cloudbreak -c 'sh /start_cb_shell.sh'
