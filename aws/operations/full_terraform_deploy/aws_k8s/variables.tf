variable "glean_instance_name" {
  description = "Glean instance name"
  type        = string
}

variable "account_id" {
  description = "AWS account ID to use"
  type        = string
}

variable "region" {
  description = "AWS region to use"
  type        = string
}

variable "default_tags" {
  description = "Default tags to attach k8s-created AWS resources via annotations"
  type        = map(string)
}

variable "version_tag" {
  type        = string
  description = "Version tag to use"
}

variable "bastion_port" {
  description = "The port on which to open bastion connections"
  type        = string
  default     = null
}

variable "cluster_name" {
  description = "The name of the Kubernetes cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "The endpoint of the Kubernetes cluster"
  type        = string
}

variable "cluster_ca_cert_data" {
  description = "Base-64 encoded CA cert data for the Kubernetes cluster"
  type        = string
}

variable "kubernetes_token_command" {
  description = "Command to use for generating the K8s auth token for the kubernetes provider"
  type        = string
}

variable "kubernetes_token_generation_command_args" {
  description = "Args to pass to the command used to generate the K8s auth token for the kubernetes provider"
  type        = list(string)
}

variable "deploy_jobs_nodegroup" {
  description = "Name of the nodegroup to use for deploy jobs"
  type        = string
}

variable "deploy_jobs_namespace" {
  description = "Name of the namespace to use for running deploy jobs"
  type        = string
}

variable "deploy_jobs_service_account" {
  description = "Name of the service account to use for running deploy jobs"
  type        = string
}

variable "nodegroup_node_selector_key" {
  description = "Key to use for selecting K8s nodes based on the nodegroup, e.g. eks.amazonaws.com/nodegroup for AWS"
  type        = string
}

variable "default_env_vars" {
  description = "Any default environment variables to attach to k8s workloads"
  type        = map(string)
  default     = {}
}

variable "app_name_env_vars" {
  description = "Any environment variables to attach to k8s workloads based on their app names"
  type        = list(string)
  default     = []
}

variable "referential_env_vars" {
  description = "A mapping of env var -> spec path for all k8s environment variables based on pod specs"
  type        = map(string)
  default     = {}
}

variable "config_handler_image_uri" {
  description = "Image URI to use for the the config_handler runs (for making config/ipjc updates)"
  type        = string
}


variable "initialize_config_job_id" {
  description = "Job ID of the INITIALIZE_CONFIG job, used to link a dependency between that job in the core k8s module and all config/ipjc updates in this module"
  type        = string
}

variable "unvalidated_ssl_cert_arn" {
  description = "ARN of the ACM SSL cert, should not be validated yet"
  type        = string
}

variable "alb_role_arn" {
  description = "ARN of the IAM role to attach to ALB controller service account"
  type        = string
}

variable "alb_nodegroup" {
  description = "Name of the nodegroup to use for the ALB controller"
  type        = string
}

variable "additional_k8s_admin_role_arns" {
  description = "List of role arns to grant master privileges on the cluster"
  type        = list(string)
  default     = []
}

variable "eks_worker_node_arn" {
  description = "ARN of the EKS worker node IAM role"
  type        = string
}

variable "self_hosted_airflow_nodes_iam_role_arn" {
  description = "ARN of the self hosted airflow IAM role"
  type        = string
}

variable "codebuild_role_arn" {
  description = "ARN of the codebuild IAM role"
  type        = string
}

variable "cron_helper_role_arn" {
  description = "ARN of the cron_helper IAM role"
  type        = string
}

variable "flink_invoker_role_arn" {
  description = "ARN of the flink invoker IAM role"
  type        = string
}

variable "glean_viewer_role_arn" {
  description = "ARN of the glean-viewer IAM role"
  type        = string
}

variable "gmp_collector_role_arn" {
  description = "ARN of the gmp collector role arn"
  type        = string
}

variable "deploy_job_role_arn" {
  description = "ARN of the deploy job IAM role"
  type        = string
}

variable "opensearch_1_namespace" {
  description = "Name of first Opensearch namespace"
  type        = string
}

variable "opensearch_2_namespace" {
  description = "Name of second Opensearch namespace"
  type        = string
}

variable "elastic_compute_role_arn" {
  description = "ARN of the elastic (opensearch) compute IAM role"
  type        = string
}

variable "external_ingress_lb_host_name" {
  description = "Host name of the k8s ingress that supports the external ALB"
  type        = string
}