variable "known_glean_ip" {
  type        = string
  description = "The known IP of Glean's central service to interact with the deployment"
  default     = "35.239.35.180"
}

variable "known_glean_canary_ip" {
  type        = string
  description = "The known IP of the Glean's canary central service"
  default     = "104.198.208.205"
}

variable "known_glean_central_datasources_ip" {
  type        = string
  description = "The known IP of Glean's central datasources IP"
  default     = "104.154.230.46"
}

variable "region" {
  description = "The region to use for WAF resources"
  type        = string
  default     = "us-east-1"
}


variable "default_tags" {
  description = "Tags that need to be associated with all resources by default"
  type        = map(string)
  default     = {}
}

# Note: for some frustrating reason, terraform doesn't let you set the rate limiting window
# and forces you to look over a 5 minute window. So we must project each count we'd normally
# enforce in cloud armor over a 5 minute span. This is why these default values are different
# than those in terraform/glean.com/google/modules/waf/variables.tf

variable "actas_rate_limiting_count" {
  type        = number
  description = "ActAs rating limiting count"
}

variable "autocomplete_rate_limiting_count" {
  type        = number
  description = "autocomplete (non-critical call) rate limiting count"
}

variable "ask_rate_limiting_count" {
  type        = number
  description = "ask (expensive call) rate limiting count"
}

variable "search_rate_limiting_count" {
  type        = number
  description = "search (expensive call) rate limiting count"
}

# TODO: track this one in config with gcp
variable "debug_rate_limiting_count" {
  type        = number
  description = "debug (expensive call) rate limiting count"
  default     = 100
}

variable "country_red_list" {
  type        = list(string)
  description = "Country Red List"
}

variable "ip_red_list" {
  type        = list(string)
  description = "A list of IPs (in CIDR format) to reject"
}

variable "ip_green_list" {
  type        = list(string)
  description = "A list specific IPs (in CIDR format) to permit access"
}

variable "allow_canary_ipjc_ingress" {
  type        = bool
  description = "Whether to allow ipjc ingress traffic from the canary central project"
  default     = false
}

variable "block-ugc-write-endpoints" {
  type        = bool
  description = "If true, blocks all UGC write endpoints"
  default     = false
}

# Note this maps to `enableModSecurity`. GCP has ModSecurity, AWS has the baseline rule groups.
variable "enforce_baseline_rule_set" {
  type        = bool
  description = "If true, this will block traffic in the AWS baseline rule groups"
  default     = false
}

variable "block_user_agents" {
  type        = list(string)
  description = "User agents to block"
  default     = []
}

variable "nat_gateway_public_ip" {
  type        = string
  description = "The NAT gateway public IP"
}

variable "anonymous_ip_preview" {
  type        = bool
  description = "Switch to enable AWS Managed WAF modules for blocking Anonymous IP reputation rule groups to be used for PREVIEW only."
}

variable "anonymous_ip_enforcement" {
  type        = bool
  description = "Switch to enable AWS Managed WAF modules for blocking Anonymous IP reputation rule groups for ENFORCING only."
}

variable "ip_waf_rule_lists_preview" {
  type        = bool
  description = "Switch to enable AWS Managed WAF modules regarding IP reputation rule groups to be used for PREVIEW only."
}

variable "ip_waf_rule_lists_enforcement" {
  type        = list(string)
  description = "This is a list of AWS Managed WAF modules regarding IP reputation rule groups to be used for ENFORCEMENT only."

  validation {
    condition     = alltrue([for item in var.ip_waf_rule_lists_enforcement : contains(["AWSManagedIPReputationList", "AWSManagedReconnaissanceList", "AWSManagedIPDDoSList"], item)])
    error_message = "Valid values for var.supplemental_aws_waf_modules_enforcement are (\"AWSManagedIPReputationList\", \"AWSManagedReconnaissanceList\", \"AWSManagedIPDDoSList\")"
  }
}
