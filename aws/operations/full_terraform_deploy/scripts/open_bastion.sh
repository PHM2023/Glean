#!/bin/bash
set -e

eval "$(jq -r '@sh "LOCAL_PORT=\(.local_port) REGION=\(.region) BASTION_INSTANCE_ID=\(.bastion_instance_id)"')"

aws ssm start-session \
    --target $BASTION_INSTANCE_ID \
    --document-name AWS-StartPortForwardingSession \
    --parameters '{"portNumber":["8888"], "localPortNumber":["'${LOCAL_PORT}'"]}' --region $REGION >/dev/null 2>/tmp/bastion_stderr.log &


# Wait for the connection to come up
sleep 5


# Tells terraform the connection is open
echo "{ \"port\": \"$LOCAL_PORT\" }"
