output "initialize_config_job_id" {
  value = module.initialize_config.job_id
}

output "flink_watchdog_namespace" {
  value = kubernetes_namespace.flink_watchdog_namespace.metadata[0].name
}


output "flink_invoker_namespace" {
  value = kubernetes_namespace.flink_invoker_namespace.metadata[0].name
}

output "opensearch_1_namespace" {
  value = kubernetes_namespace.elasticsearch_1_namespace.metadata[0].name
}

output "opensearch_2_namespace" {
  value = kubernetes_namespace.elasticsearch_2_namespace.metadata[0].name
}

output "dse_internal_lb_service_hostname" {
  value = kubernetes_service_v1.dse_internal_lb_service.status[0].load_balancer[0].ingress[0].hostname
}

output "external_ingress_lb_host_name" {
  value = kubernetes_ingress_v1.glean_ingress.status[0].load_balancer[0].ingress[0].hostname
}
