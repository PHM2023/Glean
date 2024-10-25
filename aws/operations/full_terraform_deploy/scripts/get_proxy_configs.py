import configparser
import json
import random
import string
import sys
from typing import Any, Dict, List
from urllib.parse import urlparse

import boto3
from botocore.exceptions import ClientError

PEER_ACCOUNT_ID_CONFIG_KEY = 'aws.tgwPeerAccountId'
PEER_REGION_CONFIG_KEY = 'aws.tgwPeerRegion'
PEER_TGW_ID_CONFIG_KEY = 'aws.tgwPeerId'
ACCEPTED_TGW_PEERING_ATTACHMENT_ID_CONFIG_KEY = 'aws.acceptedTgwPeeringAttachmentId'
USE_TRANSIT_GATEWAY_PEERING_CONFIG_KEY = 'aws.useTransitGatewayPeering'
ACCEPTED_ATTACHMENT_OWNER_ACCOUNT_ID_CONFIG_KEY = 'aws.tgwPeeringAttachmentOwnerAccountId'
GLEAN_TGW_ID_CONFIG_KEY = 'aws.gleanTgwId'


def enumerate_onprem_datasources(config: configparser.RawConfigParser) -> List[str]:
    onprem_datasources = []
    for section in config.sections():
        if 'onprem.host' not in config[section] or not config[section]['onprem.host']:
            continue
        onprem_datasources.append(section)
    return onprem_datasources


def get_onprem_routing_ips(config: configparser.RawConfigParser) -> List[str]:
    ips = []
    for datasource in enumerate_onprem_datasources(config):
        if config[datasource].get('onprem.skipAddingRoute', 'false').lower() == 'true':
            continue
        if 'onprem.ip' in config[datasource] and config[datasource]['onprem.ip']:
            ips.append(f"{config[datasource]['onprem.ip']}/32")
    return ips


def should_create_proxy(config) -> bool:
    return config.getboolean('setup', 'proxy.enabled') and config.get('setup', 'transit.range')


def get_onprem_datasource_host(config: configparser.RawConfigParser, datasource: str) -> str:
    if 'onprem.host' in config[datasource]:
        host = config[datasource]['onprem.host']
    else:
        base_url = config[datasource]['onprem.baseURL']
        parsed_url = urlparse(base_url)
        host = parsed_url.hostname
    return host


def get_onprem_host_aliases(config: configparser.RawConfigParser) -> Dict[str, str]:
    host_aliases = {}
    for datasource in enumerate_onprem_datasources(config):
        if 'onprem.ip' not in config[datasource] or not config[datasource]['onprem.ip']:
            continue
        ip = config[datasource]['onprem.ip']
        host = get_onprem_datasource_host(config, datasource)
        host_aliases[host] = ip
    # NOTE: additional host aliases override the IP if the host already exists
    # in the map.
    additional_host_aliases = str(config['setup']['proxy.additionalHostAliases'])
    if additional_host_aliases:
        for pair in additional_host_aliases.split(','):
            if pair:
                kv = pair.split(':')
                if len(kv) != 2:
                    raise RuntimeError(f'Invalid additional host alias format {additional_host_aliases}')
                host_aliases[kv[0]] = kv[1]
    return host_aliases


def _postprocess_configs_for_terraform(configs: Dict[str, Any]) -> Dict[str, str]:
    # Terraform expects a map of string -> string as the output
    new_configs = {}
    for key, value in configs.items():
        if value is None:
            raise RuntimeError(f'Unexpected null value for config key: {key}')
        elif isinstance(value, str):
            new_configs[key] = value
        elif isinstance(value, list):
            new_configs[key] = ','.join(value)
        elif isinstance(value, dict):
            new_configs[key] = ','.join([f'{k}={v}' for k, v in value.items()])
        elif isinstance(value, bool) or isinstance(value, int):
            new_configs[key] = str(value).lower()
    return new_configs


def _config_as_string_list(config: configparser.RawConfigParser, section: str, option: str) -> List[str]:
    string_list = config.get(section, option, fallback=None)
    if not string_list:
        return []
    return string_list.split(',')


def main():
    json_input = sys.stdin.read()
    tf_info = json.loads(json_input)
    account_id = tf_info['account_id']
    region = tf_info.get('region')
    default_config_path = tf_info['default_config_path']
    custom_config_path = tf_info.get('custom_config_path')

    config = configparser.ConfigParser()
    config.optionxform = str
    with open(default_config_path, encoding='utf-8') as df:
        config.read_file(df)

    s3_client = boto3.client('s3', region_name=region)
    try:
        dynamic_config_str = (s3_client.get_object(Bucket=f'config-{account_id}',
                                                   Key='dynamic.ini')['Body'].read().decode('utf-8'))
        config.read_string(dynamic_config_str)
    except (s3_client.exceptions.NoSuchBucket, s3_client.exceptions.NoSuchKey):
        # Config bucket and/or file is not created yet, fall back to default.ini
        pass

    if custom_config_path:
        with open(custom_config_path, encoding='utf-8') as cf:
            config.read_file(cf)

    proxy_configs = {}
    proxy_configs['transit_vpc_cidr'] = config.get('setup', 'transit.range')
    proxy_configs['proxy_remote_subnets'] = _config_as_string_list(config, 'setup', 'proxy.remoteSubnets')
    proxy_configs['proxy_onprem_ips'] = get_onprem_routing_ips(config)
    proxy_configs['proxy_nameservers'] = _config_as_string_list(config, 'setup', 'proxy.nameservers')

    proxy_configs['should_create_proxy'] = bool(should_create_proxy(config))
    vpn_peer_ip = config.get('setup', 'vpn.peerIp', fallback='')
    use_transit_gateway_peering = config.getboolean('setup', USE_TRANSIT_GATEWAY_PEERING_CONFIG_KEY)
    if vpn_peer_ip and use_transit_gateway_peering:
        raise ValueError('Cannot use both VPN and standalone transit gateway')
    proxy_configs['vpn_peer_ip'] = vpn_peer_ip
    proxy_configs['transit_gateway_peering'] = use_transit_gateway_peering
    existing_attachment_id = config.get('setup', ACCEPTED_TGW_PEERING_ATTACHMENT_ID_CONFIG_KEY, fallback=None)
    if use_transit_gateway_peering:
        proxy_configs['tgw_peer_account_id'] = config.get('setup', PEER_ACCOUNT_ID_CONFIG_KEY)
        proxy_configs['tgw_peer_region'] = config.get('setup', PEER_REGION_CONFIG_KEY)
        proxy_configs['tgw_peer_gateway_id'] = config.get('setup', PEER_TGW_ID_CONFIG_KEY)
        proxy_configs['tgw_peered_attachment_id'] = existing_attachment_id
    else:
        existing_attachment_owner = config.get('setup', ACCEPTED_ATTACHMENT_OWNER_ACCOUNT_ID_CONFIG_KEY)
        if existing_attachment_id and existing_attachment_owner != account_id:
            # We won't have this resource block in our terraform file, so we delete it prior to running so that
            # terraform can clean up smoothly
            proxy_configs['old_tgw_to_delete'] = existing_attachment_id
    proxy_configs['onprem_host_aliases'] = get_onprem_host_aliases(config)
    if vpn_peer_ip:
        try:
            secrets_manager_client = boto3.client('secretsmanager', region_name=region)
            vpn_shared_secret = secrets_manager_client.get_secret_value(SecretId='vpn-shared-secret')['SecretString']
        except ClientError as e:
            if e.response['Error']['Code'] != 'ResourceNotFoundException':
                raise e
            # Set to random if we are doing first pass VPN setup, in which we just create our end of the VPN tunnel
            # to get a target IP to give to the customer. After that, they provide us with the shared secret
            vpn_shared_secret = ''.join(random.choice(string.ascii_letters) for _ in range(32))
        proxy_configs['vpn_shared_secret'] = vpn_shared_secret
        # Secret is encrypted us a TF data block

    print(json.dumps(_postprocess_configs_for_terraform(proxy_configs)))


if __name__ == '__main__':
    main()
