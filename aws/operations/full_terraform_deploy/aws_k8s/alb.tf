# Create k8s service account and link with AWS IAM Role
resource "kubernetes_service_account" "alb_controller_service_account" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = var.alb_role_arn
    }
    labels = {
      "app.kubernetes.io/component" : "controller",
      "app.kubernetes.io/name" : "aws-load-balancer-controller"
    }
  }
}


resource "helm_release" "alb_helm_release" {
  chart      = "aws-load-balancer-controller"
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.alb_controller_service_account.metadata[0].name
  }
  # Set node selector and tolerations so we choose the right node group
  set {
    name  = "nodeSelector.eks\\.amazonaws\\.com/nodegroup"
    value = var.alb_nodegroup
  }
  set {
    name  = "tolerations[0].key"
    value = "alb"
  }
  set {
    name  = "tolerations[0].value"
    value = "enabled"
  }
  set {
    name  = "tolerations[0].effect"
    value = "NoSchedule"
  }
  set {
    name  = "tolerations[0].operator"
    value = "Equal"
  }
}