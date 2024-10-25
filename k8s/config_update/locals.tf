locals {
  config_writes = {
    for k, v in var.config_key_values : k => v if v != null
  }
  config_deletes = [
    for k, v in var.config_key_values : k if v == null
  ]
}