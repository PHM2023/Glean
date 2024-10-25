locals {
  aws_baseline_rule_set_suffix   = var.enforce_baseline_rule_set ? "Enforcing" : "PreviewOnly"
  country_code_chunks            = chunklist(var.country_red_list, 5)
  block_user_agents_chunks       = var.block_user_agents != null ? chunklist(var.block_user_agents, 5) : []
  glean_central_ip_set_addresses = concat(["${var.known_glean_ip}/32", "${var.known_glean_central_datasources_ip}/32"], var.allow_canary_ipjc_ingress ? ["${var.known_glean_canary_ip}/32"] : [])
}
