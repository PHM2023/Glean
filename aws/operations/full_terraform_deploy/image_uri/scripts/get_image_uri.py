import json
import sys

import boto3


def _get_image_uri(
    repo_name: str,
    version_tag: str,
    region: str,
    registry: str,
) -> str:
    us_east_1_ecr_client = boto3.client('ecr', region_name=region)
    image_response = us_east_1_ecr_client.describe_images(registryId=registry,
                                                          repositoryName=repo_name,
                                                          imageIds=[{
                                                              'imageTag': version_tag
                                                          }])
    image_digest = image_response['imageDetails'][0]['imageDigest']
    return f'{registry}.dkr.ecr.{region}.amazonaws.com/{repo_name}@{image_digest}'


def main():
    json_input = sys.stdin.read()
    tf_info = json.loads(json_input)
    repo_name = tf_info['repo_name']
    version_tag = tf_info['version_tag']
    region = tf_info['region']
    registry = tf_info['registry']
    print(json.dumps({'image_uri': _get_image_uri(repo_name, version_tag, region, registry)}))


if __name__ == '__main__':
    main()
