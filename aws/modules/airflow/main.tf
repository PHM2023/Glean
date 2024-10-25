data "aws_eks_cluster" "glean_cluster" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.glean_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.glean_cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.glean_cluster.name]
    command     = "aws"
  }
  proxy_url = var.use_bastion ? try("http://localhost:7972", null) : null
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.glean_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.glean_cluster.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.glean_cluster.name]
      command     = "aws"
    }
    proxy_url = var.use_bastion ? try("http://localhost:7972", null) : null
  }
}

data "aws_iam_role" "self_hosted_airflow_nodes_iam_role" {
  name = "AirflowNodesIAMRole"
}

##################### Self Hosted Airflow ################################
### Create airflow nodegroup ###

resource "aws_eks_node_group" "self_hosted_airflow_node_group" {
  cluster_name    = var.cluster_name
  node_group_name = "airflow-nodegroup"
  node_role_arn   = data.aws_iam_role.self_hosted_airflow_nodes_iam_role.arn
  subnet_ids      = [var.eks_private_subnet_id]

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 2
  }
  instance_types = ["t3.xlarge"]

  labels = {
    app : "airflow-chomp"
  }

  taint {
    key    = "airflow-chomp"
    value  = "True"
    effect = "NO_SCHEDULE"
  }
}


### Retrieve database connection endpoint, password ###
data "aws_db_instance" "airflow_rds_instance" {
  db_instance_identifier = "airflow-instance"
}


data "aws_secretsmanager_secret" "airflow-db-secret" {
  name = "airflow_rds_instance_root_password"
}

data "aws_secretsmanager_secret_version" "airflow-db-secret-current" {
  secret_id = data.aws_secretsmanager_secret.airflow-db-secret.id
}

### Create keda helm release ###

resource "kubernetes_namespace" "keda_namespace" {
  metadata {
    name = "keda"
  }
}

resource "helm_release" "keda" {
  name       = "keda"
  repository = "https://kedacore.github.io/charts"
  chart      = "keda"
  namespace  = "keda"
  depends_on = [
    kubernetes_namespace.keda_namespace
  ]
}

### Create airflow helm release ###
resource "kubernetes_namespace" "self_hosted_airflow_namespace" {
  metadata {
    name = "airflow"
  }
}

resource "helm_release" "self_hosted_airflow" {
  name      = "self-hosted-airflow"
  chart     = "../../../../../deploy/configs/airflow/chart"
  namespace = "airflow"
  values = [
    file("../../../../../deploy/configs/airflow/chart/aws_deployment_overrides.yaml")
  ]
  set {
    name = "workers.env[0].value" # key: DB_CONN
    value = format(
      "root:%s@tcp(%s:3306)/airflow_db",
      data.aws_secretsmanager_secret_version.airflow-db-secret-current.secret_string,
      data.aws_db_instance.airflow_rds_instance.address
    )
  }
  set {
    name  = "data.metadataConnection.pass"
    value = data.aws_secretsmanager_secret_version.airflow-db-secret-current.secret_string
  }
  set {
    name  = "data.metadataConnection.host"
    value = data.aws_db_instance.airflow_rds_instance.address
  }

  set {
    name  = "workers.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = data.aws_iam_role.self_hosted_airflow_nodes_iam_role.arn
  }

  set {
    name  = "webserver.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = data.aws_iam_role.self_hosted_airflow_nodes_iam_role.arn
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = data.aws_iam_role.self_hosted_airflow_nodes_iam_role.arn
  }

  set {
    name  = "config.logging.remote_base_log_folder"
    value = "s3://glean-airflow-logs-${var.account_id}"
  }

  set {
    name = "airflow.connections[0].extra"
    value = jsonencode({
      "region_name" : var.region
    })
  }

  depends_on = [
    helm_release.keda,
    kubernetes_namespace.self_hosted_airflow_namespace,
    aws_eks_node_group.self_hosted_airflow_node_group
  ]
}
