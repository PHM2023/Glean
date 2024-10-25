import base64
import os
from typing import Dict

import boto3
import docker

_AWS_GLEAN_ENGINEERING_ACCOUNT_ID = '518642952506'
_AWS_GLEAN_ENGINEERING_ECR_REGION = 'us-east-1'
_DOCKER_API_TIMEOUT_SECS = 1200


def _get_docker_auth_config(ecr_registry_id: str, region: str) -> Dict[str, str]:
    ecr_client = boto3.client('ecr', region_name=region)
    token = ecr_client.get_authorization_token(registryIds=[ecr_registry_id])
    username, password = base64.b64decode(token['authorizationData'][0]['authorizationToken']).decode().split(':')
    return {'username': username, 'password': password}


# Downloads the image from the Glean-central us-east-1 repo, then re-uploads to the dedicated regional repo for this
# account
def _preprocess_docker_image(repo_name: str, tag: str, account_id: str, region: str):
    # First, lookup the built image in the central us-east-1 repo
    us_east_1_ecr_client = boto3.client('ecr', region_name=_AWS_GLEAN_ENGINEERING_ECR_REGION)
    image_response = us_east_1_ecr_client.describe_images(registryId=_AWS_GLEAN_ENGINEERING_ACCOUNT_ID,
                                                          repositoryName=repo_name,
                                                          imageIds=[{
                                                              'imageTag': tag
                                                          }])
    image_digest = image_response['imageDetails'][0]['imageDigest']
    us_east_1_image = f'{_AWS_GLEAN_ENGINEERING_ACCOUNT_ID}.dkr.ecr.{_AWS_GLEAN_ENGINEERING_ECR_REGION}.amazonaws.com/{repo_name}:{tag}'

    # Then check if the image has already been pushed to this account's regional ECR repo (checking both the tag and
    # digest)
    regional_ecr_client = boto3.client('ecr', region_name=region)
    try:
        response = regional_ecr_client.describe_images(registryId=account_id,
                                                       repositoryName=repo_name,
                                                       imageIds=[{
                                                           'imageDigest': image_digest
                                                       }])
        # We found the right digest, but we also have to ensure the tag is there too
        for image in response.get('imageDetails', []):
            if tag in image.get('imageTags', []):
                print(f'Using existing regional image for repo {repo_name} with digest {image_digest} and tag {tag}')
                return
        print(f'Did not find desired tag {tag} attached to image with digest {image_digest} - proceeding with normal '
              f'pre-processing to update the tags')
    except regional_ecr_client.exceptions.ImageNotFoundException:
        # Image not found, download and re-upload it now
        pass

    docker_client = docker.from_env(timeout=_DOCKER_API_TIMEOUT_SECS)

    # Then, download the image from the us-east-1 ecr and tag it with the regional image
    print(f'Downloading {us_east_1_image} locally...')
    us_east_1_auth_config = _get_docker_auth_config(_AWS_GLEAN_ENGINEERING_ACCOUNT_ID, 'us-east-1')
    docker_client.images.pull(us_east_1_image, auth_config=us_east_1_auth_config)
    image = docker_client.images.get(us_east_1_image)
    regional_image = f'{account_id}.dkr.ecr.{region}.amazonaws.com/{repo_name}:{tag}'
    image.tag(regional_image)

    # Finally, push to the regional ecr and delete locally
    print(f'Pushing {regional_image}...')
    regional_auth_config = _get_docker_auth_config(account_id, region)
    docker_client.images.push(regional_image, auth_config=regional_auth_config)
    docker_client.images.remove(regional_image)  # untags the core image
    docker_client.images.remove(us_east_1_image)  # deletes the core image


def main():
    repo_name = os.getenv('REPO_NAME')
    version_tag = os.getenv('VERSION_TAG')
    account_id = os.getenv('ACCOUNT_ID')
    region = os.getenv('REGION')
    _preprocess_docker_image(repo_name, version_tag, account_id, region)


if __name__ == '__main__':
    main()
