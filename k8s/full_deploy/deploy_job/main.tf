
locals {
  tag_suffix = var.run_once ? "" : "-${replace(replace(var.general_info.tag, ".", "-"), "_", "-")}"
  # k8s jobs don't allow '_' and must be lowercase
  op_name          = lower(replace(var.operation, "_", "-"))
  extra_args_str   = join(",", [for k, v in var.general_info.extra_args : "${k}=${v}"])
  shorted_job_name = substr("${local.op_name}${local.tag_suffix}", 0, 63)
  final_job_name   = endswith(local.shorted_job_name, "-") ? substr(local.shorted_job_name, 0, length(local.shorted_job_name) - 1) : local.shorted_job_name
}

resource "kubernetes_job" "deploy_job" {
  metadata {
    # K8s job names can be max 63 characters
    name      = local.final_job_name
    namespace = var.general_info.deploy_jobs_namespace
  }
  # wait_for_completion and timeouts have to be used in conjunction for the resource to block until the
  # job actually succeeds:
  # https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/job.html#timeouts
  wait_for_completion = true
  timeouts {
    create = "${var.timeout_minutes}m"
    update = "${var.timeout_minutes}m"
  }
  lifecycle {
    # Ignore the job spec changes and only rerun on a name (version) change
    ignore_changes = [spec]
  }
  spec {
    # Don't clean up the job if only running once. Otherwise, preserver the job for 24h so it doesn't rerun needlessly.
    ttl_seconds_after_finished = var.run_once ? null : "86400"
    backoff_limit              = var.retries
    template {
      metadata {}
      spec {
        toleration {
          key    = "service"
          value  = "glean-deploy-jobs"
          effect = "NoSchedule"
        }
        node_selector = {
          (var.general_info.nodegroup_node_selector_key) : var.general_info.deploy_jobs_nodegroup
        }
        service_account_name = var.general_info.deploy_jobs_k8s_service_account
        container {
          name  = "deploy"
          image = var.general_info.deploy_image_uri
          args = concat([
            "--noself_deploy",
            "--operation=${var.operation}",
            "--tag=${var.general_info.tag}",
            "--scio_instance=${var.general_info.glean_instance_name}",
            "--extra_args=${local.extra_args_str}",
          ], var.expand_ops ? [] : ["--skip_ops_expansion"])
          dynamic "env" {
            for_each = var.general_info.default_env_vars
            content {
              name  = env.key
              value = env.value
            }
          }
          dynamic "env" {
            for_each = var.general_info.referential_env_vars
            content {
              name = env.key
              value_from {
                field_ref {
                  field_path = env.value
                }
              }
            }
          }
          dynamic "env" {
            for_each = toset(var.general_info.app_name_env_vars)
            content {
              name  = env.key
              value = "deploy"
            }
          }
          env {
            name = "BUILD_ID"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }
          resources {
            limits = {
              cpu    = "1000m"
              memory = "4Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "2Gi"
            }
          }
        }
      }
    }
  }
}
