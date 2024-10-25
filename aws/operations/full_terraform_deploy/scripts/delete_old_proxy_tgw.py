import os

import boto3
from botocore.exceptions import ClientError


def main():
    tgw_to_delete = os.getenv('TGW_TO_DELETE')
    region = os.getenv('REGION')
    try:
        client = boto3.client('ec2', region_name=region)
        client.delete_transit_gateway_peering_attachment(TransitGatewayAttachmentId=tgw_to_delete)
    except ClientError as e:
        if e.response['Error']['Code'] == 'InvalidTransitGatewayAttachmentID.NotFound':
            print(f'Suppressing: transit gateway peering attachment {tgw_to_delete} does not exist')
        else:
            raise


if __name__ == '__main__':
    main()
