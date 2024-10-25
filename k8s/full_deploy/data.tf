data "external" "rabbitmq_secret_gen" {
  program = [
    "bash",
    "${path.module}/scripts/generate_rabbitmq_secrets.sh"
  ]
  query = {}
}

data "external" "ingress_rules" {
  program = ["python", "${path.module}/scripts/get_ingress_rules.py"]
  query = {
    "ingress_paths_root" : var.ingress_paths_root
  }
}