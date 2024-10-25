
locals {
  # k8s jobs don't allow '_' and must be lowercase
  op_name          = lower(replace(var.update_name, "_", "-"))
  shorted_job_name = substr(local.op_name, 0, 63)
  final_job_name   = endswith(local.shorted_job_name, "-") ? substr(local.shorted_job_name, 0, length(local.shorted_job_name) - 1) : local.shorted_job_name
}

resource "kubernetes_job" "config_update_job" {
  metadata {
    # K8s job names can be max 63 characters
    name      = local.final_job_name
    namespace = var.general_info.namespace
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
    # Ignore things that can drift but aren't the actual config/ipjc update contents, e.g. the image uri
    ignore_changes = [
      spec[0].template[0].spec[0].container[0].image,
      spec[0].template[0].spec[0].container[0].env,
      spec[0].template[0].spec[0].toleration,
      spec[0].template[0].spec[0].node_selector,
      spec[0].template[0].spec[0].service_account_name
    ]
  }
  spec {
    # Never clean up the job. It will only re-run if the config/ipjc updates change
    ttl_seconds_after_finished = null
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
          (var.general_info.nodegroup_node_selector_key) : var.general_info.nodegroup
        }
        service_account_name = var.general_info.service_account
        container {
          name  = "deploy"
          image = var.general_info.config_handler_image_uri
          args = concat([
            "--path=${var.path}",
            "--ipjc_channel_path=${var.ipjc_channel_path}",
            "--ipjc_request_body='${var.ipjc_request_body}'"
            ], [for key, value in local.config_writes : "--config_key_value=${key}=${value}"],
          [for key in local.config_deletes : "--config_delete=${key}"])
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