import configparser
import json
import sys

import boto3


def main():
    json_input = sys.stdin.read()
    tf_info = json.loads(json_input)
    account_id = tf_info['account_id']
    region = tf_info['region']
    config_keys_to_read = tf_info['keys'].split(',')
    default_config_path = tf_info['default_config_path']
    custom_config_path = tf_info.get('custom_config_path')

    full_config = configparser.ConfigParser()
    full_config.optionxform = str
    with open(default_config_path, encoding='utf-8') as df:
        full_config.read_file(df)

    s3_client = boto3.client('s3', region_name=region)
    try:
        dynamic_config_str = (s3_client.get_object(Bucket=f'config-{account_id}',
                                                   Key='dynamic.ini')['Body'].read().decode('utf-8'))
        full_config.read_string(dynamic_config_str)
    except (s3_client.exceptions.NoSuchBucket, s3_client.exceptions.NoSuchKey):
        # Config bucket and/or file is not created yet, fall back to default.ini
        pass

    if custom_config_path:
        with open(custom_config_path, encoding='utf-8') as cf:
            full_config.read_file(cf)

    key_to_section_key = {key: key.split('.', maxsplit=1) for key in config_keys_to_read}
    key_values = {key: full_config.get(sk[0], sk[1]) for key, sk in key_to_section_key.items()}
    print(json.dumps(key_values))


if __name__ == '__main__':
    main()
