module "common_logging_sinks" {
  source = "../../../common/logging_sinks"
}

locals {
  export_filter_pattern = "{ $.resource.type = \"k8s_container\" || $.resource.type = \"aws_lambda_function\" || $.resource.type = \"generic_task\" || $.resource.type = \"aws_alb_load_balancer\"}"
  # for now, only export flink, elastic/opensearch, and k8s event logs
  # TODO: update this or make it config-driven
  containers_to_export_from_fb = [
    "k8s-event-logger",
    "crawler",
    "dse",
    "admin",
    "qe",
    "rabbitmq",
    "task-push",
    "clamav-scanner",
    "basic-fim-scanner",
    "basic-fim-logger",
    "http-cron-job",
    "lambda-cron-job",
    # For deploy jobs running as part of the full terraform module
    "deploy"
    # TODO: also add qp/scholastic to this list, but we can't for now because logs are currently duped to stackdriver/fluent bit
  ]
  container_filter_clauses           = join(" || ", [for container in local.containers_to_export_from_fb : "$.kubernetes.container_name = \"${container}\""])
  fluent_bit_exporter_filter_pattern = "{ $.kubernetes.container_name = %flink% || $.kubernetes.pod_name = %elasticsearch% || ${local.container_filter_clauses} }"
  externally_exported_log_names = [
    for export in values(module.common_logging_sinks.external_bq_log_sinks) : export.log_name
  ]
  lambda_logs_to_export = [for name in [
    "cron_helper",
    "upgrade_opensearch_nodepool",
    "ingress_logs_processor"
  ] : "/aws/lambda/${name}"]
}