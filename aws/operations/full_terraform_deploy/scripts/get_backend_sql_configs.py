import json
import sys

import boto3

_MYSQL_ENGINE = 'mysql'
_MYSQL_VERSION = '8.0.33'

_BACKEND_SQL_INSTANCE_SIZE_TIER_MAP = {
    'small': 100,
    # note: 400 allows us to provision more IOPS if needed
    'medium': 400,
    'large': 700,
    'xlarge': 1000,
}

_BACKEND_SQL_R6_INSTANCE_CLASS_TIER_MAP = {
    'small': 'db.r6g.large',
    'medium': 'db.r6g.4xlarge',
    'large': 'db.r6g.12xlarge',
    'xlarge': 'db.r6g.16xlarge',
}

_BACKEND_SQL_R7_INSTANCE_CLASS_TIER_MAP = {
    'small': 'db.r7g.large',
    'medium': 'db.r7g.4xlarge',
    'large': 'db.r7g.12xlarge',
    'xlarge': 'db.r7g.16xlarge',
}


def _get_instance_class_for_tier_and_region(tier: str, region: str) -> str:
    rds_client = boto3.client('rds', region_name=region)
    # first, see if r7g instances are offered in this region - otherwise, use r6, which are more widely available
    response = rds_client.describe_orderable_db_instance_options(Engine=_MYSQL_ENGINE,
                                                                 EngineVersion=_MYSQL_VERSION,
                                                                 DBInstanceClass='db.r7g.large')
    options = response.get('OrderableDBInstanceOptions', [])
    if options:
        return _BACKEND_SQL_R7_INSTANCE_CLASS_TIER_MAP[tier]
    return _BACKEND_SQL_R6_INSTANCE_CLASS_TIER_MAP[tier]


def main():
    # Tries the config first, then falls back to seed values based on tier
    json_input = sys.stdin.read()
    tf_info = json.loads(json_input)
    region = tf_info['region']
    initial_tier = tf_info.get('initial_deployment_tier')
    class_from_config = tf_info.get('class_from_config')
    size_from_config = tf_info.get('size_from_config')
    configs = {}

    if class_from_config:
        configs['class'] = class_from_config
    elif initial_tier:
        configs['class'] = _get_instance_class_for_tier_and_region(initial_tier, region)
    else:
        raise RuntimeError(f'Either the `initial_deployment_tier` var or the `aws.backendInstance.instanceClass` '
                           f'config must be set')

    if size_from_config:
        configs['size'] = size_from_config
    elif initial_tier:
        configs['size'] = str(_BACKEND_SQL_INSTANCE_SIZE_TIER_MAP[initial_tier])
    else:
        raise RuntimeError(f'Either the `initial_deployment_tier` var or the `aws.backendInstance.storageSize` config '
                           f'must be set')

    print(json.dumps(configs))


if __name__ == '__main__':
    main()
