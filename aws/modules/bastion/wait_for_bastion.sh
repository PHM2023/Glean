#!/bin/sh
# Waits until the SSM agent is online within the bastion instance and it's ready to be used for proxying
set -e

REGION=$1
INSTANCE_ID=$2

ONLINE_ID=$(aws ssm describe-instance-information --region $REGION --filters Key=InstanceIds,Values=$INSTANCE_ID Key=PingStatus,Values=Online --query 'InstanceInformationList[0].InstanceId' --output text)
while [[ "$ONLINE_ID" != "$INSTANCE_ID" ]]; do
  echo "Bastion SSM agent not online yet..."
  sleep 5
  ONLINE_ID=$(aws ssm describe-instance-information --region $REGION --filters Key=InstanceIds,Values=$INSTANCE_ID Key=PingStatus,Values=Online --query 'InstanceInformationList[0].InstanceId' --output text)
done

echo "Bastion SSM agent is online and ready to use"
