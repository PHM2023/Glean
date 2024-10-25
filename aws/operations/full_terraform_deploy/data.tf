data "external" "ssh_tunnel" {
  count = var.use_bastion ? 1 : 0
  program = [
    "bash",
    "${path.module}/scripts/open_bastion.sh"
  ]
  query = {
    local_port = var.bastion_port
    region     = var.region
    # This ensures that we wait until bastion is online until we start the tunnel
    bastion_instance_id = module.bastion.bastion_instance_id
  }
}


data "external" "backend_sql_configs" {
  program = ["python", "${path.module}/scripts/get_backend_sql_configs.py"]
  query = {
    "region" : var.region,
    "initial_deployment_tier" : var.initial_deployment_tier,
    "class_from_config" : module.sql_configs.values["sql.aws.backendInstance.instanceClass"],
    "size_from_config" : module.sql_configs.values["sql.aws.backendInstance.storageSize"]
  }
}

data "aws_iam_policy" "cloudwatch_agent_policy" {
  name = "CloudWatchAgentServerPolicy"
}

data "aws_iam_role" "codebuild" {
  name = "codebuild"
}

data "aws_iam_role" "glean_viewer" {
  name = "glean-viewer"
}


data "external" "proxy_configs" {
  program = ["python", "${path.module}/scripts/get_proxy_configs.py"]
  query = {
    "account_id" : var.account_id,
    "region" : var.region,
    "default_config_path" : var.default_config_path,
    "custom_config_path" : var.custom_config_path,
  }
}

data "local_file" "set_google_credentials_in_aws_file" {
  filename = "../../../../../deploy/configs/aws/set-google-credentials-in-aws.sh"
}
