# This setup follows: https://aws.amazon.com/blogs/storage/migrating-google-cloud-storage-to-amazon-s3-using-aws-datasync/

# First, we create the iam role, policy, and instance profile
resource "aws_iam_role" "activity-data-transporter-role" {
  name                 = "activity-data-transporter"
  permissions_boundary = var.iam_permissions_boundary_arn
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "datasync.amazonaws.com"
        },
        "Action" : "sts:AssumeRole",
        "Condition" : {
          "StringEquals" : {
            "aws:SourceAccount" : var.account_id
          },
          "StringLike" : {
            "aws:SourceArn" : "arn:aws:datasync:${var.region}:${var.account_id}:*"
          }
        }
      }
    ]
  })
}

data "aws_s3_bucket" "query-metadata-bucket" {
  bucket = "scio-${var.account_id}-query-metadata"
}

data "aws_s3_bucket" "elastic-snapshots-bucket" {
  bucket = "elastic-snapshots-${var.account_id}"
}

locals {
  bucket_resources             = [for bucket, _ in var.s3-to-gcs-activity-buckets : "arn:aws:s3:::${bucket}"]
  bucket_prefixes              = [for bucket_resource in local.bucket_resources : "${bucket_resource}/*"]
  query_metadata_bucket_arn    = "arn:aws:s3:::${data.aws_s3_bucket.query-metadata-bucket.id}"
  elastic_snapshots_bucket_arn = "arn:aws:s3:::${data.aws_s3_bucket.elastic-snapshots-bucket.id}"
  eval_set_subdirectory        = "perf_test/query_log_evalset"
}

resource "aws_iam_policy" "activity-data-transporter-policy" {
  name = "ActivityDataTransporterPolicy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads"
        ],
        "Effect" : "Allow",
        "Resource" : concat(local.bucket_resources, [local.query_metadata_bucket_arn, local.elastic_snapshots_bucket_arn])
      },
      {
        "Action" : [
          "s3:AbortMultipartUpload",
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:GetObjectTagging",
          "s3:GetObjectVersion",
          "s3:GetObjectVersionTagging",
          "s3:ListMultipartUploadParts",
          "s3:PutObject",
          "s3:PutObjectTagging"
        ],
        "Effect" : "Allow",
        "Resource" : concat(local.bucket_prefixes, ["${local.query_metadata_bucket_arn}/*", "${local.elastic_snapshots_bucket_arn}/*"])
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "activity-transporter-policy-attachment" {
  role       = aws_iam_role.activity-data-transporter-role.name
  policy_arn = aws_iam_policy.activity-data-transporter-policy.arn
}

resource "aws_iam_instance_profile" "activity-data-transporter" {
  name = "activity-data-transporter"
  role = aws_iam_role.activity-data-transporter-role.name
}


data "aws_ssm_parameter" "datasync-ami-ssm-parameter" {
  name = "/aws/service/datasync/ami"
}

data "aws_vpc" "glean-vpc" {
  filter {
    name   = "tag:Name"
    values = ["glean-vpc"]
  }
}

# we can reuse the bastion subnet
data "aws_subnet" "bastion-subnet" {
  filter {
    name   = "tag:Name"
    values = ["bastion-private-subnet"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.glean-vpc.id]
  }
}

data "aws_security_group" "bastion_security_group" {
  name = "bastion-security-group"
}

data "aws_security_group" "codebuild_security_group" {
  name = "codebuild-security-group"
}

# Next, we create security groups for the ec2 instance used for the datasync agent and the vpc endpoint it will use
resource "aws_security_group" "activity-data-transporter-security-group" {
  name   = "activity-data-transporter-security-group"
  vpc_id = data.aws_vpc.glean-vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "activity-data-ingress-self-rule" {
  security_group_id            = aws_security_group.activity-data-transporter-security-group.id
  description                  = "For allowing connections from within the sg"
  referenced_security_group_id = aws_security_group.activity-data-transporter-security-group.id
  ip_protocol                  = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow-codebuild-ingress" {
  security_group_id            = aws_security_group.activity-data-transporter-security-group.id
  description                  = "For allowing connections from codebuild deploys"
  referenced_security_group_id = data.aws_security_group.codebuild_security_group.id
  ip_protocol                  = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow-bastion-ingress" {
  security_group_id            = aws_security_group.activity-data-transporter-security-group.id
  description                  = "For allowing connections from bastion"
  referenced_security_group_id = data.aws_security_group.bastion_security_group.id
  ip_protocol                  = "-1"
}

resource "aws_vpc_security_group_egress_rule" "activity-data-egress-rule" {
  security_group_id = aws_security_group.activity-data-transporter-security-group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "datasync-vpc-endpoint-security-group" {
  name   = "datasync-vpc-security-group"
  vpc_id = data.aws_vpc.glean-vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "datasync-vpc-endpoint-self-rule" {
  security_group_id            = aws_security_group.datasync-vpc-endpoint-security-group.id
  description                  = "For allowing connections from within the sg"
  referenced_security_group_id = aws_security_group.datasync-vpc-endpoint-security-group.id
  ip_protocol                  = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "datasync-vpc-endpoint-agent-rule" {
  security_group_id            = aws_security_group.datasync-vpc-endpoint-security-group.id
  description                  = "For allowing connections from the datasync agent"
  referenced_security_group_id = aws_security_group.activity-data-transporter-security-group.id
  ip_protocol                  = "-1"
}

resource "aws_vpc_security_group_egress_rule" "datasync-vpc-endpoint-egress-rule" {
  security_group_id = aws_security_group.datasync-vpc-endpoint-security-group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_endpoint" "datasync-vpc-endpoint" {
  vpc_id            = data.aws_vpc.glean-vpc.id
  service_name      = "com.amazonaws.${var.region}.datasync"
  vpc_endpoint_type = "Interface"
  tags = {
    Name = "datasync-vpc-endpoint"
  }
  security_group_ids = [aws_security_group.datasync-vpc-endpoint-security-group.id]
  subnet_ids         = [data.aws_subnet.bastion-subnet.id]
  depends_on = [
    aws_vpc_security_group_ingress_rule.datasync-vpc-endpoint-agent-rule,
    aws_vpc_security_group_ingress_rule.datasync-vpc-endpoint-self-rule,
    aws_vpc_security_group_egress_rule.datasync-vpc-endpoint-egress-rule
  ]
}

# Then we create the instance, waiting for the security groups and vpc endpoint above to be ready first
resource "aws_instance" "activity-data-transporter" {
  ami = data.aws_ssm_parameter.datasync-ami-ssm-parameter.value

  instance_type = var.instance_type

  tags = {
    Name = "activity-data-transporter"
  }

  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.activity-data-transporter.name

  subnet_id = data.aws_subnet.bastion-subnet.id

  vpc_security_group_ids = [aws_security_group.activity-data-transporter-security-group.id]
  depends_on = [
    aws_vpc_endpoint.datasync-vpc-endpoint,
    aws_vpc_security_group_ingress_rule.activity-data-ingress-self-rule,
    aws_vpc_security_group_ingress_rule.allow-codebuild-ingress,
    aws_vpc_security_group_ingress_rule.allow-bastion-ingress,
    aws_vpc_security_group_egress_rule.activity-data-egress-rule
  ]
  lifecycle {
    # ignore changes to the ami after creation, otherwise the agent will be deactivated
    ignore_changes = [ami]
  }
}

data "aws_network_interface" "datasync-vpc-endpoint-eni" {
  id = one(aws_vpc_endpoint.datasync-vpc-endpoint.network_interface_ids)
}

# Now we have to create the datasync agent. To do this, we need an activation key that can only be retrieved by making
# a GET request to a known URI on the datasync instance:
# https://docs.aws.amazon.com/datasync/latest/userguide/create-agent-cli.html

# In the http data block below, we have to hit the datasync instance on its private ip once it's available. Here we
# explicitly wait to the check the instance is running
resource "null_resource" "check-datasync-agent-instance-is-available" {

  provisioner "local-exec" {
    when    = create
    command = <<-EOT

#!/bin/bash
instance_status="unknown"
while [ "$instance_status" != "ok" ];
do
  instance_status=$(aws ec2 describe-instance-status --instance-ids '${aws_instance.activity-data-transporter.id}' --region ${var.region} --output text --query 'InstanceStatuses[0].InstanceStatus.Status')
done

    EOT
  }
}

# Also, the agent activation key request will fail after the agent's already been activated, which will break this
# data block. Hence, we have to use the skip-agent-activation-request var to skip this entirely for repeated runs.
data "http" "datasync-agent-activation-key-request" {
  count      = var.skip-agent-activation-key-request ? 0 : 1
  url        = "http://${aws_instance.activity-data-transporter.private_ip}/?gatewayType=SYNC&activationRegion=${var.region}&privateLinkEndpoint=${data.aws_network_interface.datasync-vpc-endpoint-eni.private_ip}&endpointType=PRIVATE_LINK&no_redirect"
  depends_on = [null_resource.check-datasync-agent-instance-is-available]
}

resource "aws_datasync_agent" "activity-datasync-agent" {
  activation_key      = var.skip-agent-activation-key-request ? "" : data.http.datasync-agent-activation-key-request[0].body
  name                = "activity-datasync-agent"
  vpc_endpoint_id     = aws_vpc_endpoint.datasync-vpc-endpoint.id
  subnet_arns         = [data.aws_subnet.bastion-subnet.arn]
  security_group_arns = [aws_security_group.datasync-vpc-endpoint-security-group.arn]
  lifecycle {
    # ignore any updates to the activation key after creation, since, as mentioned above, the activation key should
    # only be created once
    ignore_changes = [activation_key]
  }
}

# Finally, we create the datasync locations (s3 + gcs buckets) and tasks. We'll use use these base tasks to run
# either periodic/on-demand copies
resource "aws_datasync_location_s3" "activity-bucket-locations-s3" {
  for_each      = toset(local.bucket_resources)
  s3_bucket_arn = each.key
  subdirectory  = ""
  s3_config {
    bucket_access_role_arn = aws_iam_role.activity-data-transporter-role.arn
  }
}

# A separate location for the query metadata bucket so we can sync eval sets as well
resource "aws_datasync_location_s3" "query-metadata-bucket-location-s3" {
  s3_bucket_arn = local.query_metadata_bucket_arn
  subdirectory  = local.eval_set_subdirectory
  s3_config {
    bucket_access_role_arn = aws_iam_role.activity-data-transporter-role.arn
  }
}

# A separate location for the elastic snapshots bucket so we can sync old snapshots as well
resource "aws_datasync_location_s3" "elastic-snapshots-bucket-location-s3" {
  s3_bucket_arn = local.elastic_snapshots_bucket_arn
  # to not overwrite current snapshots
  subdirectory = "gcs_snapshots"
  s3_config {
    bucket_access_role_arn = aws_iam_role.activity-data-transporter-role.arn
  }
}

# Assumes we've already set a secret for the GCS HMAC key used to authenticate. This will be manual step for now
data "aws_secretsmanager_secret" "gcs-access-credentials-secret" {
  name = "gcs-activity-data-credentials"
}

data "aws_secretsmanager_secret_version" "gcs-access-credentials-data" {
  secret_id = data.aws_secretsmanager_secret.gcs-access-credentials-secret.id
}

locals {
  gcs_access_credentials_json = jsondecode(data.aws_secretsmanager_secret_version.gcs-access-credentials-data.secret_string)
}

resource "aws_datasync_location_object_storage" "activity-bucket-locations-gcs" {
  for_each        = var.s3-to-gcs-activity-buckets
  agent_arns      = [aws_datasync_agent.activity-datasync-agent.arn]
  server_hostname = "storage.googleapis.com"
  bucket_name     = each.value
  access_key      = local.gcs_access_credentials_json["access_key"]
  secret_key      = local.gcs_access_credentials_json["secret"]
}

resource "aws_datasync_location_object_storage" "query-metadata-bucket-location-gcs" {
  agent_arns      = [aws_datasync_agent.activity-datasync-agent.arn]
  server_hostname = "storage.googleapis.com"
  bucket_name     = var.gcs_query_metadata_bucket
  access_key      = local.gcs_access_credentials_json["access_key"]
  secret_key      = local.gcs_access_credentials_json["secret"]
  subdirectory    = local.eval_set_subdirectory
}

resource "aws_datasync_location_object_storage" "elastic-snapshots-bucket-location-gcs" {
  agent_arns      = [aws_datasync_agent.activity-datasync-agent.arn]
  server_hostname = "storage.googleapis.com"
  bucket_name     = var.gcs_elastic_snapshots_bucket
  access_key      = local.gcs_access_credentials_json["access_key"]
  secret_key      = local.gcs_access_credentials_json["secret"]
}

locals {
  gcs_bucket_to_source_arn = { for location in aws_datasync_location_object_storage.activity-bucket-locations-gcs : location.bucket_name => location.arn }
  s3_bucket_to_source_arn  = { for s3_location in aws_datasync_location_s3.activity-bucket-locations-s3 : trimprefix(s3_location.s3_bucket_arn, "arn:aws:s3:::") => s3_location.arn }
}

# Note this doesn't actually start the sync, it just creates the task configs that we can then execute on demand
resource "aws_datasync_task" "activity-data-transport-tasks" {
  for_each = var.s3-to-gcs-activity-buckets
  name     = "${each.key}-sync-task"

  destination_location_arn = local.s3_bucket_to_source_arn[each.key]
  source_location_arn      = local.gcs_bucket_to_source_arn[each.value]
  options {
    posix_permissions = "NONE"
    uid               = "NONE"
    gid               = "NONE"
  }
}

resource "aws_datasync_task" "query-metadata-eval-set-task" {
  name                     = "${data.aws_s3_bucket.query-metadata-bucket.id}-sync-task"
  destination_location_arn = aws_datasync_location_s3.query-metadata-bucket-location-s3.arn
  source_location_arn      = aws_datasync_location_object_storage.query-metadata-bucket-location-gcs.arn
  options {
    posix_permissions = "NONE"
    uid               = "NONE"
    gid               = "NONE"
  }
}

resource "aws_datasync_task" "elastic-snapshots-task" {
  name                     = "${data.aws_s3_bucket.elastic-snapshots-bucket.id}-sync-task"
  destination_location_arn = aws_datasync_location_s3.elastic-snapshots-bucket-location-s3.arn
  source_location_arn      = aws_datasync_location_object_storage.elastic-snapshots-bucket-location-gcs.arn
  options {
    posix_permissions = "NONE"
    uid               = "NONE"
    gid               = "NONE"
  }
}
