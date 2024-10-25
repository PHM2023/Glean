output "lb_host_name" {
  value = var.use_lb_service ? kubernetes_service_v1.service.status[0].load_balancer[0].ingress[0].hostname : ""
}
