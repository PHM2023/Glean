variable "deploy_job_general_info" {
  description = "General info for running GMP deploy jobs"
  type        = any
}

variable "service_account_iam_annotation" {
  description = "Annotation key-value for IAM attachment to k8s service account"
  type = object({
    key   = string
    value = string
  })
}

variable "cluster_name" {
  description = "The name of the Kubernetes cluster"
  type        = string
}


variable "monitoring_gcp_project_id" {
  description = "The gcp project id to use for monitoring and observability"
  type        = string
}

variable "set_google_credentials_file_content" {
  description = "Contents of the relevant set-google-credentials-script"
  type        = string
}