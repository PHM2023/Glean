
##################### Flink K8s Resources ################################
# Installs flink kubernetes operator using helm charts

resource "kubernetes_namespace" "flink_jobs_namespace" {
  metadata {
    name = var.flink_jobs_namespace
  }
}

resource "kubernetes_namespace" "flink_operator_namespace" {
  metadata {
    name = var.flink_operator_namespace
  }
}

resource "helm_release" "flink_kubernetes_operator" {
  name      = "flink-kubernetes-operator"
  chart     = "${path.module}/../../../../deploy/configs/flink/flink-kubernetes-operator"
  namespace = kubernetes_namespace.flink_operator_namespace.metadata[0].name

  set {
    name  = "watchNamespaces"
    value = "{${kubernetes_namespace.flink_jobs_namespace.metadata[0].name}}"
  }

  # TODO (Vaibhav) Enable this once we add cert-manager setup. Setting this to false disables CRD validation.
  set {
    name  = "webhook.create"
    value = "false"
  }
}

###################### Flink Watchdog ##########################

resource "kubernetes_namespace" "flink_watchdog_namespace" {
  metadata {
    name = "flink-watchdog"
  }
}

resource "kubernetes_cluster_role" "flink_watchdog_cluster_role" {
  metadata {
    name = "flink-watchdog-cluster-role"
  }
  rule {
    verbs = [
      "get",
      "list",
      "patch"
    ]
    resources = [
      "services",
      "pods"
    ]
    api_groups = [""]
  }
  rule {
    verbs      = ["get", "list"]
    resources  = ["jobs"]
    api_groups = ["batch"]
  }
  rule {
    verbs = [
      "get",
      "list",
      "delete",
      "patch"
    ]
    resources = [
      "flinkdeployments",
      "flinkdeployment"
    ]
    api_groups = ["flink.apache.org"]
  }
  rule {
    verbs = [
      "get",
      "list",
      "delete"
    ]
    resources = [
      "namespace",
      "namespaces"
    ]
    api_groups = [""]
  }
  rule {
    verbs = [
      "create",
      "get"
    ]
    resources = [
      "services/portforward",
      "pods/portforward"
    ]
    api_groups = [""]
  }
}

resource "kubernetes_service_account" "flink_watchdog_ksa" {
  metadata {
    name      = "flink-watchdog-ksa"
    namespace = kubernetes_namespace.flink_watchdog_namespace.metadata[0].name

    annotations = {
      (var.service_account_iam_annotation_key) : var.service_account_iam_annotations.flink_watchdog
    }
  }
}


resource "kubernetes_cluster_role_binding" "flink_watchdog_cluster_role_binding" {
  metadata {
    name = "flink-watchdog-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.flink_watchdog_cluster_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.flink_watchdog_ksa.metadata[0].name
    namespace = kubernetes_namespace.flink_watchdog_namespace.metadata[0].name
  }
}

###################### Flink Jobs #########################

# The "flink" k8s service account is automatically created by the flink operator in the flink-jobs namespace. We just
# need to add the annotation to link it to the IAM role.
resource "kubernetes_annotations" "flink_sa_role_annotation" {
  api_version = "v1"
  kind        = "ServiceAccount"
  metadata {
    name      = "flink"
    namespace = kubernetes_namespace.flink_jobs_namespace.metadata[0].name
  }
  annotations = {
    (var.service_account_iam_annotation_key) : var.service_account_iam_annotations.flink_java_jobs
  }
  depends_on = [helm_release.flink_kubernetes_operator]
}

###################### Flink Invoker ######################

# Namespace in which the invoker jobs will run
resource "kubernetes_namespace" "flink_invoker_namespace" {
  metadata {
    name = "flink-invoker-jobs"
  }
}

# Cluster role for setting up namespace, creating jobs, etc.
resource "kubernetes_cluster_role" "flink_invoker_cluster_role" {
  metadata {
    name = "flink-invoker-cluster-role"
  }
  # Rule to allow creating Beam SDK Harness service account
  rule {
    verbs = [
      "create",
      "get",
      "patch",
      "update"
    ]
    resources = [
      "serviceaccount",
      "serviceaccounts"
    ]
    api_groups = [""]
  }
  # Rule to allow creating namespace for the job
  rule {
    verbs = [
      "create",
      "get",
      "list",
      "patch",
      "delete"
    ]
    resources = [
      "namespace",
      "namespaces"
    ]
    api_groups = [""]
  }
  # Rule to allow creating configmaps (for the flink config), services (for job manager, task managers)
  rule {
    verbs = [
      "create",
      "get",
      "list",
      "delete"
    ]
    resources = [
      "configmaps",
      "pods",
      "services"
    ]
    api_groups = [""]
  }
  # Rule to allow creating statefulsets (for job manager, task managers)
  rule {
    verbs = [
      "create",
      "get",
      "list",
      "delete"
    ]
    resources = [
      "statefulsets",
    ]
    api_groups = ["apps"]
  }
  # Rule to allow port forwarding to the job manager
  rule {
    verbs = [
      "create",
      "get",
      "list"
    ]
    resources = [
      "services/portforward",
      "pods/portforward"
    ]
    api_groups = [""]
  }
}

resource "kubernetes_service_account" "flink_invoker_ksa" {
  metadata {
    name      = "flink-invoker-ksa"
    namespace = kubernetes_namespace.flink_invoker_namespace.metadata[0].name
    annotations = {
      (var.service_account_iam_annotation_key) : var.service_account_iam_annotations.flink_invoker
    }
  }
}

# Create cluster role binding for the service account
resource "kubernetes_cluster_role_binding" "flink_invoker_cluster_role_binding" {
  metadata {
    name = "flink-invoker-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.flink_invoker_cluster_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.flink_invoker_ksa.metadata[0].name
    namespace = kubernetes_namespace.flink_invoker_namespace.metadata[0].name
  }
}
