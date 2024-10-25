
##################### Enables metrics server for HPA ################################

resource "helm_release" "metrics_server_helm_release" {
  name             = "metrics-server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart            = "metrics-server"
  namespace        = "kube-system"
  create_namespace = true
  version          = "3.11.0"
  set {
    name  = "podDisruptionBudget.enabled"
    value = "true"
  }
  set {
    name  = "podDisruptionBudget.minAvailable"
    value = "1"
  }
}
