resource "kubernetes_config_map_v1" "set_google_credentials_in_aws" {
  metadata {
    name      = "set-google-credentials-in-aws"
    namespace = kubernetes_namespace_v1.gmp_system.metadata[0].name
  }

  data = {
    # TODO: rename this to something platform-agnostic
    "set-google-credentials-in-aws.sh" = var.set_google_credentials_file_content
  }
}

resource "kubernetes_namespace_v1" "gmp_system" {
  metadata {
    name = "gmp-system"
  }
}
resource "kubernetes_namespace_v1" "gmp_public" {
  metadata {
    name = "gmp-public"
  }
}

resource "kubernetes_config_map_v1" "rules_generated" {
  metadata {
    name      = "rules-generated"
    namespace = kubernetes_namespace_v1.gmp_system.metadata[0].name
    labels = {
      "app.kubernetes.io/name" : "rule-evaluator"
    }
  }
  data = {
    "empty.yaml" = ""
  }
}

resource "kubernetes_service_account_v1" "gmp_collector" {
  automount_service_account_token = true
  metadata {
    ######## BEGIN Glean gmp collector ksa role association ############
    # Prefix name with gmp- and add ksa annotation to associate with the gmp-collector role
    name      = "gmp-collector"
    namespace = kubernetes_namespace_v1.gmp_system.metadata[0].name
    annotations = {
      (var.service_account_iam_annotation.key) : var.service_account_iam_annotation.value
    }
    ######## END Glean gmp collector ksa role association ############
  }
}

resource "kubernetes_service_account_v1" "gmp_operator_service_account" {
  metadata {
    name      = "operator"
    namespace = kubernetes_namespace_v1.gmp_system.metadata[0].name
  }
}

resource "kubernetes_cluster_role_v1" "gmp_collector_cluster_role" {
  metadata {
    name = "gmp-system:gmp-collector"
  }
  rule {
    resources = [
      "endpoints",
      "nodes",
      "nodes/metrics",
      "pods",
      "services"
    ]
    api_groups = [""]
    verbs = [
      "get",
      "list",
      "watch"
    ]
  }
  rule {
    verbs      = ["get"]
    api_groups = [""]
    resources  = ["configmaps"]
  }
  rule {
    verbs             = ["get"]
    non_resource_urls = ["/metrics"]
  }
}

resource "kubernetes_role_v1" "operator_system_role" {
  metadata {
    name      = "operator"
    namespace = kubernetes_namespace_v1.gmp_system.metadata[0].name
  }
  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["list", "watch", "create"]
  }
  rule {
    api_groups     = [""]
    resources      = ["secrets"]
    resource_names = ["collection", "rules", "alertmanager"]
    verbs          = ["get", "patch", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["list", "watch", "create"]
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    resource_names = [
      "collector",
      "rule-evaluator",
      kubernetes_config_map_v1.rules_generated.metadata[0].name
    ]
    verbs = ["get", "patch", "update"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["daemonsets"]
    verbs = [
      "get",
      "list",
      "watch",
      "delete",
      "patch",
      "update"
    ]
    resource_names = ["collector"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs      = ["list", "watch"]
  }
  rule {
    api_groups     = ["apps"]
    resources      = ["deployments"]
    resource_names = ["rule-evaluator"]
    verbs = [
      "get",
      "delete",
      "patch",
    "update"]
  }
  rule {
    api_groups     = [""]
    resource_names = ["alertmanager"]
    resources      = ["services"]
    verbs = ["get",
      "list",
    "watch"]
  }
}

resource "kubernetes_role_v1" "operator_public_role" {
  metadata {
    name      = "operator"
    namespace = kubernetes_namespace_v1.gmp_public.metadata[0].name
  }
  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs = ["get",
      "list",
    "watch"]
  }
  rule {
    api_groups = ["monitoring.googleapis.com"]
    resources  = ["operatorconfigs"]
    verbs = ["get",
      "list",
    "watch"]
  }
}

resource "kubernetes_cluster_role_v1" "gmp_system_operator" {
  metadata {
    name = "gmp-system:operator"
  }
  rule {
    verbs = ["get",
      "patch",
      "update",
    "watch"]
    resource_names = ["gmp-operator.gmp-system.monitoring.googleapis.com"]
    api_groups     = ["admissionregistration.k8s.io"]
    resources = ["validatingwebhookconfigurations",
    "mutatingwebhookconfigurations"]
  }
  rule {
    verbs          = ["delete"]
    resource_names = ["gmp-operator"]
    api_groups     = ["admissionregistration.k8s.io"]
    resources = ["validatingwebhookconfigurations",
    "mutatingwebhookconfigurations"]
  }
  rule {
    verbs = ["get",
      "list",
    "watch"]
    api_groups = ["monitoring.googleapis.com"]
    resources = ["clusterpodmonitorings",
      "clusterrules",
      "globalrules",
      "podmonitorings",
    "rules"]
  }
  rule {
    verbs = ["get",
      "patch",
    "update"]
    resources = ["clusterpodmonitorings/status",
      "clusterrules/status",
      "globalrules/status",
      "podmonitorings/status",
    "rules/status"]
    api_groups = ["monitoring.googleapis.com"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "gmp_system_operator" {
  metadata {
    name = "gmp-system:operator"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.gmp_system_operator.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.gmp_operator_service_account.metadata[0].name
    namespace = kubernetes_namespace_v1.gmp_system.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding_v1" "gmp_system_collector" {
  metadata {
    name = "gmp-system:gmp-collector"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.gmp_collector_cluster_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.gmp_collector.metadata[0].name
    namespace = kubernetes_namespace_v1.gmp_system.metadata[0].name
  }
}

resource "kubernetes_role_binding_v1" "gmp_public_operator" {
  metadata {
    name      = "operator"
    namespace = kubernetes_namespace_v1.gmp_public.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.operator_public_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    namespace = kubernetes_namespace_v1.gmp_system.metadata[0].name
    name      = kubernetes_service_account_v1.gmp_operator_service_account.metadata[0].name
  }
}

resource "kubernetes_role_binding_v1" "gmp_system_operator" {
  metadata {
    name      = "operator"
    namespace = kubernetes_namespace_v1.gmp_system.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.operator_system_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.gmp_operator_service_account.metadata[0].name
    namespace = kubernetes_namespace_v1.gmp_system.metadata[0].name
  }
}

resource "kubernetes_service_v1" "gmp_operator" {
  metadata {
    name      = "gmp-operator"
    namespace = kubernetes_namespace_v1.gmp_system.metadata[0].name
  }
  spec {
    selector = {
      "app.kubernetes.io/component" : "operator",
      "app.kubernetes.io/name" : "gmp-operator",
      "app.kubernetes.io/part-of" : "gmp"
    }
    port {
      port        = 8443
      target_port = "webhook"
      name        = "legacy"
      protocol    = "TCP"
    }
    port {
      port        = 443
      protocol    = "TCP"
      target_port = "web"
      name        = "webhook"
    }
  }
}

resource "kubernetes_priority_class_v1" "gmp_critical" {
  value = 1000000000
  metadata {
    name = "gmp-critical"
  }
  description = "Used for GMP collector pods."
}


resource "kubernetes_deployment_v1" "gmp_rule_evaluator" {
  depends_on = [kubernetes_deployment_v1.gmp_operator_deployment]
  metadata {
    name      = "rule-evaluator"
    namespace = kubernetes_namespace_v1.gmp_system.metadata[0].name
  }
  spec {
    replicas = "1"
    selector {
      match_labels = {
        "app.kubernetes.io/name" : "rule-evaluator"
      }
    }
    template {
      metadata {
        labels = {
          "app" : "managed-prometheus-rule-evaluator",
          "app.kubernetes.io/name" : "rule-evaluator",
          "app.kubernetes.io/version" : "0.8.2"
        }
        annotations = {
          "cluster-autoscaler.kubernetes.io/safe-to-evict" : "true",
          "components.gke.io/component-name" : "managed_prometheus"
        }
      }
      spec {
        service_account_name            = kubernetes_service_account_v1.gmp_collector.metadata[0].name
        automount_service_account_token = true
        priority_class_name             = kubernetes_priority_class_v1.gmp_critical.metadata[0].name
        enable_service_links            = false
        init_container {
          name  = "config-init"
          image = "gke.gcr.io/gke-distroless/bash:20220419"
          command = [
            "/bin/bash",
            "-c",
            "touch /prometheus/config_out/config.yaml"
          ]
          volume_mount {
            mount_path = "/prometheus/config_out"
            name       = "config-out"
          }
          security_context {
            run_as_group               = "1000"
            run_as_non_root            = true
            run_as_user                = "1000"
            allow_privilege_escalation = false
            capabilities {
              drop = ["all"]
            }
            privileged = false
            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
        }
        init_container {
          name  = "glean-set-google-credentials-in-aws"
          image = "amazon/aws-cli:2.1.34"
          command = [
            "/bin/bash",
            "-c",
            "mkdir -p /tmp/glean && cp /var/lib/glean/set-google-credentials-in-aws.sh /tmp/glean/set-google-credentials-in-aws.sh && chmod +x /tmp/glean/set-google-credentials-in-aws.sh && /tmp/glean/set-google-credentials-in-aws.sh --google_credentials_in_aws_output_path=/etc/stackdriver-exporter-key/stackdriver-exporter-key.json"
          ]
          volume_mount {
            mount_path = "/var/lib/glean"
            name       = "set-google-credentials-in-aws"
          }
          volume_mount {
            mount_path = "/etc/stackdriver-exporter-key"
            name       = "gmp-stackdriver-exporter-key"
          }
          security_context {
            allow_privilege_escalation = true
            run_as_user                = "0"
            privileged                 = true
          }
        }
        container {
          name  = "config-reloader"
          image = "gke.gcr.io/prometheus-engine/config-reloader:v0.8.1-gke.6"
          args = [
            "--config-file=/prometheus/config/config.yaml",
            "--config-file-output=/prometheus/config_out/config.yaml",
            "--watched-dir=/etc/rules",
            "--watched-dir=/etc/secrets",
            "--reload-url=http://localhost:19092/-/reload",
            "--ready-url=http://localhost:19092/-/ready",
            "--listen-address=:19093"
          ]
          port {
            container_port = 19093
            name           = "cfg-rel-metrics"
          }
          resources {
            limits = {
              "memory" : "32M"
            }
            requests = {
              "cpu" : "1m",
              "memory" : "4M"
            }
          }
          volume_mount {
            mount_path = "/prometheus/config"
            name       = "config"
            read_only  = true
          }
          volume_mount {
            mount_path = "/prometheus/config_out"
            name       = "config-out"
          }
          volume_mount {
            mount_path = "/etc/rules"
            read_only  = true
            name       = "rules"
          }
          volume_mount {
            mount_path = "/etc/secrets"
            read_only  = true
            name       = "rules-secret"
          }
          security_context {
            run_as_group               = "1000"
            run_as_non_root            = true
            run_as_user                = "1000"
            allow_privilege_escalation = false
            capabilities {
              drop = ["all"]
            }
            privileged = false
            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
        }
        container {
          name  = "evaluator"
          image = "gke.gcr.io/prometheus-engine/rule-evaluator:v0.8.1-gke.6"
          args = [
            "--config.file=/prometheus/config_out/config.yaml",
            "--web.listen-address=:19092",
            "--export.user-agent-mode=kubectl"
          ]
          ####### BEGIN Add stackdriver exporter key env var for rule evaluator #######
          env {
            name  = "GOOGLE_APPLICATION_CREDENTIALS"
            value = "/etc/stackdriver-exporter-key/stackdriver-exporter-key.json"
          }
          ####### END Add stackdriver exporter key env var for rule evaluator #######
          env {
            # This environment variable is added by the gmp kubernetes operator, we add it explicitly
            # here to allow the terraform file to properly resolve
            name  = "EXTRA_ARGS"
            value = format("--export.label.project-id=\"%s\" --export.label.location=\"us-central1-a\" --export.label.cluster=\"%s\" --query.project-id=\"%s\"", var.monitoring_gcp_project_id, var.cluster_name, var.monitoring_gcp_project_id)
          }
          port {
            container_port = 19092
            name           = "r-eval-metrics"
          }
          resources {
            limits = {
              "memory" : "1G"
            }
            requests = {
              "cpu" : "1m"
              "memory" : "16M"
            }
          }
          volume_mount {
            mount_path = "/prometheus/config_out"
            read_only  = true
            name       = "config-out"
          }
          volume_mount {
            mount_path = "/etc/rules"
            read_only  = true
            name       = "rules"
          }
          volume_mount {
            mount_path = "/etc/secrets"
            read_only  = true
            name       = "rules-secret"
          }
          ###### BEGIN Add stackdriver exporter key volume mount for rule evaluator ######
          volume_mount {
            mount_path = "/etc/stackdriver-exporter-key"
            name       = "gmp-stackdriver-exporter-key"
          }
          ###### END Add stackdriver exporter key volume mount for rule evaluator ######
          liveness_probe {
            http_get {
              port   = "19092"
              path   = "/-/healthy"
              scheme = "HTTP"
            }
          }
          readiness_probe {
            http_get {
              port   = "19092"
              path   = "/-/ready"
              scheme = "HTTP"
            }
          }
          ##### BEGIN Removed pod level security context so init container can run aws creds as root #######
          security_context {
            run_as_group               = "1000"
            run_as_non_root            = true
            run_as_user                = "1000"
            allow_privilege_escalation = false
            capabilities {
              drop = ["all"]
            }
            privileged = false
            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
        }
        volume {
          name = "config"
          config_map {
            name         = "rule-evaluator"
            default_mode = "0644" # 0644 is 420 in octal, which is required by tf
          }
        }
        volume {
          name = "config-out"
          empty_dir {}
        }
        volume {
          name = "rules"
          config_map {
            name         = kubernetes_config_map_v1.rules_generated.metadata[0].name
            default_mode = "0644" # 0644 is 420 in octal, which is required by tf
          }
        }
        volume {
          name = "rules-secret"
          secret {
            default_mode = "0644" # 0644 is 420 in octal, which is required by tf
            secret_name  = "rules"
          }
        }
        ############# BEGIN Add stackdriver credentials volumes for rule evaluator ############
        volume {
          name = "set-google-credentials-in-aws"
          config_map {
            name = kubernetes_config_map_v1.set_google_credentials_in_aws.metadata[0].name
          }
        }
        volume {
          name = "gmp-stackdriver-exporter-key"
          empty_dir {}
        }
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "kubernetes.io/arch"
                  operator = "In"
                  values = [
                    "arm64",
                    "amd64"
                  ]
                }
                match_expressions {
                  key      = "kubernetes.io/os"
                  operator = "In"
                  values   = ["linux"]
                }
              }
            }
          }
        }
        toleration {
          value    = "amd64"
          effect   = "NoSchedule"
          key      = "kubernetes.io/arch"
          operator = "Equal"
        }
        toleration {
          value    = "arm64"
          effect   = "NoSchedule"
          key      = "kubernetes.io/arch"
          operator = "Equal"
        }
      }
    }
  }
}

resource "kubernetes_daemon_set_v1" "gmp_collector" {
  metadata {
    name      = "collector"
    namespace = kubernetes_namespace_v1.gmp_system.metadata[0].name
  }
  spec {
    selector {
      match_labels = {
        "app.kubernetes.io/name" : "collector"
      }
    }
    template {
      metadata {
        labels = {
          "app" : "managed-prometheus-collector",
          "app.kubernetes.io/name" : "collector",
          "app.kubernetes.io/version" : "0.8.2"
        }
        annotations = {
          "cluster-autoscaler.kubernetes.io/safe-to-evict" : "true",
          "components.gke.io/component-name" : "managed_prometheus"
        }
      }
      spec {
        service_account_name            = kubernetes_service_account_v1.gmp_collector.metadata[0].name
        automount_service_account_token = true
        priority_class_name             = kubernetes_priority_class_v1.gmp_critical.metadata[0].name
        enable_service_links            = false
        init_container {
          name  = "config-init"
          image = "gke.gcr.io/gke-distroless/bash:20220419"
          command = [
            "/bin/bash",
            "-c",
            "touch /prometheus/config_out/config.yaml"
          ]
          volume_mount {
            mount_path = "/prometheus/config_out"
            name       = "config-out"
          }
          ##### BEGIN Removed pod level security context so init container can run aws creds as root #######
          security_context {
            allow_privilege_escalation = false
            capabilities {
              drop = ["all"]
            }
            privileged      = false
            run_as_group    = "1000"
            run_as_non_root = true
            run_as_user     = "1000"
            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
          ##### END Removed pod level security context so init container can run aws creds as root #######
        }
        ######## BEGIN Add init container for collector ########
        init_container {
          name  = "glean-set-google-credentials-in-aws"
          image = "amazon/aws-cli:2.1.34"
          command = [
            "/bin/bash",
            "-c",
            "mkdir -p /tmp/glean && cp /var/lib/glean/set-google-credentials-in-aws.sh /tmp/glean/set-google-credentials-in-aws.sh && chmod +x /tmp/glean/set-google-credentials-in-aws.sh && /tmp/glean/set-google-credentials-in-aws.sh --google_credentials_in_aws_output_path=/etc/stackdriver-exporter-key/stackdriver-exporter-key.json"
          ]
          volume_mount {
            mount_path = "/var/lib/glean"
            name       = "set-google-credentials-in-aws"
          }
          volume_mount {
            mount_path = "/etc/stackdriver-exporter-key"
            name       = "gmp-stackdriver-exporter-key"
          }
          security_context {
            allow_privilege_escalation = true
            run_as_user                = "0"
            privileged                 = true
          }
        }
        ######## END Add init container for collector ########
        container {
          name  = "config-reloader"
          image = "gke.gcr.io/prometheus-engine/config-reloader:v0.8.1-gke.6"
          args = [
            "--config-file=/prometheus/config/config.yaml",
            "--config-file-output=/prometheus/config_out/config.yaml",
            "--reload-url=http://localhost:19090/-/reload",
            "--ready-url=http://localhost:19090/-/ready",
            "--listen-address=:19091"
          ]
          port {
            container_port = 19091
            name           = "cfg-rel-metrics"
          }
          env {
            name = "NODE_NAME"
            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "spec.nodeName"
              }
            }
          }
          resources {
            limits = {
              "memory" : "32M"
            }
            requests = {
              "cpu" : "1m",
              "memory" : "4M"
            }
          }
          volume_mount {
            mount_path = "/prometheus/config"
            read_only  = true
            name       = "config"
          }
          volume_mount {
            mount_path = "/prometheus/config_out"
            name       = "config-out"
          }
          ############# BEGIN Glean collector volume mounts ############
          volume_mount {
            mount_path = "/etc/stackdriver-exporter-key"
            name       = "gmp-stackdriver-exporter-key"
          }
          ############# END Glean collector volume mounts ############
          ##### BEGIN Removed pod level security context so init container can run aws creds as root #######
          security_context {
            allow_privilege_escalation = false
            capabilities {
              drop = ["all"]
            }
            privileged      = false
            run_as_group    = "1000"
            run_as_non_root = true
            run_as_user     = "1000"
            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
          ##### END Removed pod level security context so init container can run aws creds as root #######
        }
        container {
          name  = "prometheus"
          image = "gke.gcr.io/prometheus-engine/prometheus:v2.41.0-gmp.7-gke.0"
          args = [
            "--config.file=/prometheus/config_out/config.yaml",
            "--enable-feature=exemplar-storage",
            "--storage.tsdb.path=/prometheus/data",
            "--storage.tsdb.no-lockfile",
            "--storage.tsdb.retention.time=30m",
            "--storage.tsdb.wal-compression",
            "--storage.tsdb.min-block-duration=10m",
            "--storage.tsdb.max-block-duration=10m",
            "--web.listen-address=:19090",
            "--web.enable-lifecycle",
            "--web.route-prefix=/",
            "--export.user-agent-mode=kubectl",
            "--log.format=json"
          ]
          port {
            container_port = 19090
            name           = "prom-metrics"
          }
          env {
            name  = "GOGC"
            value = "25"
          }
          ####### BEGIN Env vars for collector prometheus container #######
          env {
            name  = "GOOGLE_APPLICATION_CREDENTIALS"
            value = "/etc/stackdriver-exporter-key/stackdriver-exporter-key.json"
          }
          env {
            # This environment variable is added by the gmp kubernetes operator, we add it explicitly
            # here to allow the terraform file to properly resolve
            name  = "EXTRA_ARGS"
            value = format("--export.label.project-id=\"%s\" --export.label.location=\"us-central1-a\" --export.label.cluster=\"%s\"", var.monitoring_gcp_project_id, var.cluster_name)
          }
          ####### END Env vars for collector prometheus container #######
          resources {
            limits = {
              "memory" : "2G"
            }
            requests = {
              "cpu" : "8m",
              "memory" : "32M"
            }
          }
          volume_mount {
            mount_path = "/prometheus/data"
            name       = "storage"
          }
          volume_mount {
            mount_path = "/prometheus/config_out"
            read_only  = true
            name       = "config-out"
          }
          volume_mount {
            mount_path = "/etc/secrets"
            name       = "collection-secret"
            read_only  = true
          }
          ############# BEGIN Glean collector volume mounts ############
          volume_mount {
            mount_path = "/etc/stackdriver-exporter-key"
            name       = "gmp-stackdriver-exporter-key"
          }
          ############# END Glean collector volume mounts ############
          liveness_probe {
            http_get {
              port   = "19090"
              path   = "/-/healthy"
              scheme = "HTTP"
            }
          }
          readiness_probe {
            http_get {
              port   = "19090"
              path   = "/-/ready"
              scheme = "HTTP"
            }
          }
          security_context {
            allow_privilege_escalation = false
            capabilities {
              drop = ["all"]
            }
            privileged      = false
            run_as_group    = "1000"
            run_as_non_root = true
            run_as_user     = "1000"
            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
        }
        volume {
          name = "storage"
          empty_dir {}
        }
        volume {
          name = "config"
          config_map {
            name = "collector"
          }
        }
        volume {
          name = "config-out"
          empty_dir {}
        }
        volume {
          name = "collection-secret"
          secret {
            secret_name = "collection"
          }
        }
        ############# BEGIN Add stackdriver credentials volumes for collector ############
        volume {
          name = "set-google-credentials-in-aws"
          config_map {
            name = kubernetes_config_map_v1.set_google_credentials_in_aws.metadata[0].name
          }
        }
        volume {
          name = "gmp-stackdriver-exporter-key"
          empty_dir {}
        }
        ############# END Add stackdriver credentials volumes for collector ############
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "kubernetes.io/arch"
                  operator = "In"
                  values = [
                    "arm64",
                    "amd64"
                  ]
                }
                match_expressions {
                  key      = "kubernetes.io/os"
                  operator = "In"
                  values   = ["linux"]
                }
              }
            }
          }
        }
        toleration {
          effect   = "NoExecute"
          operator = "Exists"
        }
        toleration {
          effect   = "NoSchedule"
          operator = "Exists"
        }
      }
    }
  }
}

resource "kubernetes_deployment_v1" "gmp_operator_deployment" {
  metadata {
    name      = "gmp-operator"
    namespace = kubernetes_namespace_v1.gmp_system.metadata[0].name
    labels = {
      "app" : "managed-prometheus-operator",
      "app.kubernetes.io/component" : "operator",
      "app.kubernetes.io/name" : "gmp-operator",
      "app.kubernetes.io/part-of" : "gmp"
    }
  }
  spec {
    replicas = "1"
    selector {
      match_labels = {
        "app.kubernetes.io/component" : "operator",
        "app.kubernetes.io/name" : "gmp-operator",
        "app.kubernetes.io/part-of" : "gmp"
      }
    }
    template {
      metadata {
        labels = {
          "app" : "managed-prometheus-operator",
          "app.kubernetes.io/component" : "operator",
          "app.kubernetes.io/name" : "gmp-operator",
          "app.kubernetes.io/part-of" : "gmp",
          "app.kubernetes.io/version" : "0.8.2"
        }
      }
      spec {
        service_account_name            = kubernetes_service_account_v1.gmp_operator_service_account.metadata[0].name
        automount_service_account_token = true
        priority_class_name             = kubernetes_priority_class_v1.gmp_critical.metadata[0].name
        enable_service_links            = false
        container {
          name  = "operator"
          image = "gke.gcr.io/prometheus-engine/operator:v0.8.1-gke.6"
          args = [
            "--operator-namespace=gmp-system",
            "--public-namespace=gmp-public",
            "--webhook-addr=:10250",
            ######## BEGIN Glean operator explicit credential args ########
            format("--project-id=%s", var.monitoring_gcp_project_id),
            format("--location=us-central1-a"),
            format("--cluster=%s", var.cluster_name),
            ######## END Glean operator explicit credential args ########
          ]
          port {
            container_port = 10250
            name           = "web"
          }
          port {
            container_port = 18080
            name           = "metrics"
          }
          resources {
            limits = {
              "memory" : "2G"
            }
            requests = {
              "cpu" : "1m",
              "memory" : "16M"
            }
          }
          security_context {
            allow_privilege_escalation = false
            capabilities {
              drop = ["all"]
            }
            privileged = false
          }
        }
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "kubernetes.io/arch"
                  operator = "In"
                  values = [
                    "arm64",
                    "amd64"
                  ]
                }
                match_expressions {
                  key      = "kubernetes.io/os"
                  operator = "In"
                  values   = ["linux"]
                }
              }
            }
          }
        }
        toleration {
          value    = "amd64"
          effect   = "NoSchedule"
          key      = "kubernetes.io/arch"
          operator = "Equal"
        }
        toleration {
          value    = "arm64"
          effect   = "NoSchedule"
          key      = "kubernetes.io/arch"
          operator = "Equal"
        }
        security_context {
          run_as_group    = "1000"
          run_as_non_root = true
          run_as_user     = "1000"
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }
      }
    }
  }
}
