#!/bin/bash
set -ex

# NOTE(Steve): Logs for this script can be found in /var/logs/cloud-init-output.log

sudo su -
sudo apt update
sudo apt install -y docker.io awscli jq

# Install session manager agent for remote access:
# https://docs.aws.amazon.com/systems-manager/latest/userguide/agent-install-ubuntu-64-snap.html
sudo snap install amazon-ssm-agent --classic
sudo snap start amazon-ssm-agent


# Pull image from glean-engineering repository
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 518642952506.dkr.ecr.us-east-1.amazonaws.com

# Run proxy container
# NOTE(Steve): Starting the docker container needs to be run before restarting systemd, as there seems to be a race
# condition otherwise when trying to pull the docker image; calling sleep in EC2 user code also seems to fail
# startup of the instance
sudo docker run \
  -d \
  --network=host \
  -e ALLOWED_PROXY_ADDRESS_TYPE=REMOTE \
  -e WEBHOOK_TARGET=${webhook_target} \
  -e ALLOWED_PROXY_ADDRESS=${allowed_proxy_address} \
  -p 80:80 \
  ${proxy_image}


# Add onprem host aliases to /etc/hosts
onprem_host_aliases='${onprem_host_aliases}'
declare -A host_ips_assoc
host_ips_assoc=`echo $onprem_host_aliases | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]"`
for host_ip in $${host_ips_assoc[@]}
do
    key=`echo $host_ip | cut -f1 -d'='`;
    value=`echo $host_ip | cut -f2 -d'='`;
    sudo echo "$value $key" >> /etc/hosts
done

# Add additional nameservers to resolved.conf
additional_nameservers_str='${nameservers}'
additional_nameservers=$(echo $additional_nameservers_str | jq -r '.[]')

if [ -n "$additional_nameservers_str" ]; then
  for nameserver in $${additional_nameservers[@]}; do
    echo "DNS=$nameserver" | sudo tee -a /etc/systemd/resolved.conf
  done
  # Add fallback to AWS DNS; this is an additional step from what we do in GCP, but otherwise on AWS the instance
  # will not startup at all
  # See: https://docs.aws.amazon.com/vpc/latest/userguide/AmazonDNS-concepts.html#AmazonDNS
  echo "DNS=169.254.169.253" | sudo tee -a /etc/systemd/resolved.conf
  echo "Domains=~." | sudo tee -a /etc/systemd/resolved.conf
  sudo systemctl restart systemd-resolved
fi
