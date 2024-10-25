# activity_data_sync

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.36.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.4.1 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_datasync_agent.activity-datasync-agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_agent) | resource |
| [aws_datasync_location_object_storage.activity-bucket-locations-gcs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_location_object_storage) | resource |
| [aws_datasync_location_object_storage.elastic-snapshots-bucket-location-gcs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_location_object_storage) | resource |
| [aws_datasync_location_object_storage.query-metadata-bucket-location-gcs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_location_object_storage) | resource |
| [aws_datasync_location_s3.activity-bucket-locations-s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_location_s3) | resource |
| [aws_datasync_location_s3.elastic-snapshots-bucket-location-s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_location_s3) | resource |
| [aws_datasync_location_s3.query-metadata-bucket-location-s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_location_s3) | resource |
| [aws_datasync_task.activity-data-transport-tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_task) | resource |
| [aws_datasync_task.elastic-snapshots-task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_task) | resource |
| [aws_datasync_task.query-metadata-eval-set-task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_task) | resource |
| [aws_iam_instance_profile.activity-data-transporter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.activity-data-transporter-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.activity-data-transporter-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.activity-transporter-policy-attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.activity-data-transporter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.activity-data-transporter-security-group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.datasync-vpc-endpoint-security-group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_endpoint.datasync-vpc-endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_security_group_egress_rule.activity-data-egress-rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.datasync-vpc-endpoint-egress-rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.activity-data-ingress-self-rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allow-bastion-ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allow-codebuild-ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.datasync-vpc-endpoint-agent-rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.datasync-vpc-endpoint-self-rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [null_resource.check-datasync-agent-instance-is-available](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_network_interface.datasync-vpc-endpoint-eni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/network_interface) | data source |
| [aws_s3_bucket.elastic-snapshots-bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |
| [aws_s3_bucket.query-metadata-bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |
| [aws_secretsmanager_secret.gcs-access-credentials-secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.gcs-access-credentials-data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_security_group.bastion_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |
| [aws_security_group.codebuild_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |
| [aws_ssm_parameter.datasync-ami-ssm-parameter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_subnet.bastion-subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.glean-vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [http_http.datasync-agent-activation-key-request](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The AWS account ID | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Tags that need to be associated with all resources by default | `map(string)` | `{}` | no |
| <a name="input_gcs_elastic_snapshots_bucket"></a> [gcs\_elastic\_snapshots\_bucket](#input\_gcs\_elastic\_snapshots\_bucket) | The id of the elastic snapshots bucket in the corresponding gcp deployment | `string` | n/a | yes |
| <a name="input_gcs_query_metadata_bucket"></a> [gcs\_query\_metadata\_bucket](#input\_gcs\_query\_metadata\_bucket) | The id of the query metadata bucket in the corresponding gcp deployment | `string` | n/a | yes |
| <a name="input_iam_permissions_boundary_arn"></a> [iam\_permissions\_boundary\_arn](#input\_iam\_permissions\_boundary\_arn) | Permissions boundary to apply to all IAM roles created by this module | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type to use for the datasync agent | `string` | `"m5.2xlarge"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region | `string` | `"us-east-1"` | no |
| <a name="input_s3-to-gcs-activity-buckets"></a> [s3-to-gcs-activity-buckets](#input\_s3-to-gcs-activity-buckets) | Map of s3 bucket name to corresponding gcs bucket name | `map(string)` | n/a | yes |
| <a name="input_skip-agent-activation-key-request"></a> [skip-agent-activation-key-request](#input\_skip-agent-activation-key-request) | True if we should include the agent activation. Set this to false after the agent has already been created | `bool` | `false` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
