data "external" "config_read" {
  program = ["python", "${path.module}/scripts/read_config.py"]
  query = {
    "account_id" : var.account_id,
    "region" : var.region,
    "keys" : join(",", var.keys),
    "default_config_path" : var.default_config_path,
    "custom_config_path" : var.custom_config_path
  }
}

output "values" {
  value = data.external.config_read.result
}