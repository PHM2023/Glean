terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.30.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "= 2.11.0"
    }
  }
}

# We're intentionally only putting the kubernetes and helm providers in this module to ensure it'll trigger
# only after the cluster and bastion are both ready. While it is preferred to put all providers in the root module, the
# kubernetes provider doesn't support cluster creation and k8s resource creation in the sample apply:
# https://stackoverflow.com/questions/76206678/terraform-kubernetes-provider-cannot-load-kubernetes-client-config
provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca_cert_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = var.kubernetes_token_generation_command_args
    command     = var.kubernetes_token_command
  }
  proxy_url = var.bastion_port == null ? null : "http://localhost:${var.bastion_port}"
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca_cert_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = var.kubernetes_token_generation_command_args
      command     = var.kubernetes_token_command
    }
    proxy_url = var.bastion_port == null ? null : "http://localhost:${var.bastion_port}"
  }
}