variable "region" {
  description = "The AWS region in which to deploy Glean"
  type        = string
}

variable "account_id" {
  description = "The AWS account ID to use"
  type        = string
}

variable "glean_instance_name" {
  description = "The dedicated Glean instance name to use"
  type        = string
}

variable "version_tag" {
  description = "The Glean version tag to use"
  type        = string
}

variable "default_tags" {
  description = "Tags that need to be associated with all resources by default"
  type        = map(string)
  default     = {}
}


variable "iam_permissions_boundary_arn" {
  description = "Permissions boundary to apply to all IAM roles created by this module"
  type        = string
  default     = null
}

variable "bastion_port" {
  description = "The port on which to open bastion connections"
  type        = number
  default     = 7999
}

variable "gcp_connector_project_id" {
  description = "Project ID of the Glean-owned GCP project used for monitoring and observability of the Glean instance"
  type        = string
}

variable "gcp_connector_project_number" {
  description = "Project number of the Glean-owned GCP project used for monitoring and observability"
  type        = string
}

variable "gcp_collector_service_account_client_id" {
  description = "OAuth2 client ID used to collect native metrics from CloudWatch periodically"
  type        = string
}

variable "initial_deployment_tier" {
  description = "The deployment tier for the Glean instance, must be one of: small, medium, large, xlarge. Must also be set on initial setup"
  type        = string
  validation {
    condition     = contains(["small", "medium", "large", "xlarge", ""], var.initial_deployment_tier)
    error_message = "initial_deployment_tier must be one of: small, medium, large, xlarge"
  }
  default = ""
}


variable "bastion_instance_type" {
  description = "Instance type to use for bastion proxy instance. Override this to increase bastion throughput"
  type        = string
  default     = "m4.xlarge"
}


variable "default_config_path" {
  type        = string
  description = "Path to default.ini config file"
}

variable "custom_config_path" {
  type        = string
  description = "Path to custom.ini config file (if set)"
  default     = null
}

variable "use_bastion" {
  type        = bool
  description = "Whether or not to use a bastion connection for k8s resources. Should only be set to true if not running in the glean-vpc (i.e. on the initial setup or from a standalone process)"
  default     = true
}

variable "allow_untrusted_images" {
  description = "Whether or not to allow untrusted images - should only be set for test projects"
  type        = bool
  default     = false
}

variable "allow_canary_ipjc_ingress" {
  type        = bool
  description = "Whether to allow ipjc ingress traffic from the canary central project"
  default     = false
}

variable "additional_k8s_admin_role_arns" {
  type        = list(string)
  description = "Additional role arns to grant k8s admin access"
  default     = []
}

variable "disable_account_bpa" {
  description = "This is for very special customers that want to manage their own AWS account-level S3 BPA settings. This should be FALSE by default."
  type        = bool
  default     = false
}

variable "rabbitmq_disk_size_override" {
  description = "An override for the rabbitmq disk size to handle the case where we didn't update the config for old nodegroups using a different scheme to seed the storage size"
  type        = number
  default     = null
}

# TODO: remove this after migrating workloads to new nodegroups
variable "_launch_templates_with_volume_tags_defined_first" {
  description = "List of launch template names where the volume tags should be defined first"
  type        = list(string)
  default     = []
}

variable "rollout_id" {
  description = "Rollout ID to use for each restartable k8s app. If this changes, the app will be restarted"
  type        = string
}

# TODO: remove this after migrating redis to new nodegroups
variable "_pre_existing_redis_nodegroup_name" {
  description = "Pre-existing redis nodegroup name - only set if not using the memory based nodegroups"
  type        = string
  default     = null
}

variable "_do_not_set_manually_pipelines_list" {
  # NOTE: this variable is set automatically by full_terraform_deploy.py using the expanded set of PIPELINES deploy
  # operations. We opt to use a variable instead of templating out the pipelines.tf file since that does not work
  # as well with our pre-commit terraform validation and seems more hacky.
  description = "List of Glean pipeline jobs to enable"
  type        = list(string)
  # NOTE: when packaging our terraform module for customer-initiated deployments, replace this with the full list of
  # pipelines to run so the customer does not have to supply it themselves.
  # default = [...]
}

variable "ingress_paths_root" {
  description = "Path to folder container all yamls with relevant k8s ingress rules"
  type        = string
}
