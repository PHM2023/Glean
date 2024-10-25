resource "aws_wafv2_regex_pattern_set" "ugc_write_regex_pattern_set" {
  name  = "ugc-write-pattern-set"
  scope = "REGIONAL"
  regular_expression {
    regex_string = "\\/api\\/v1\\/(create|delete|edit|update|((un)?publish)|preview|((un)?pin)|move|add).*(answer|collection|shortcut|displayablelist|announcement).*"
  }
  regular_expression {
    regex_string = "\\/api\\/v1\\/(pin|unpin|editpin)"
  }
}

resource "aws_wafv2_web_acl" "glean_waf" {
  name        = "glean-waf"
  description = "WEB ACL for Glean"
  default_action {
    allow {}
  }
  scope = "REGIONAL"
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "glean-waf"
    sampled_requests_enabled   = false
  }

  # BEGIN AWS MANAGED CORE RULE SET
  # For the AWS managed set, we will need to add in a rule with priority at 5500 to automatically
  # allow the Glean Central IPs since the AWS managed rules have false positives that can flag or block essential communication from these IPs.
  rule {
    name     = "GleanCentralIpAllow"
    priority = 5490
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.central_ip_set.arn
      }
    }

    action {
      allow {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "glean-central-ip-ingress"
      sampled_requests_enabled   = false
    }
  }

  # AWS Core Rule Set (these provide OWASP Top 10 protections):
  rule {
    # TODO UNCOMMENT BLOCKS LATER
    # name     = "CoreRuleSet${local.aws_baseline_rule_set_suffix}" # Will either be CoreRuleSetEnforcing or CoreRuleSetPreviewOnly
    name     = "CoreRuleSetPreviewOnly" # Will either be CoreRuleSetEnforcing or CoreRuleSetPreviewOnly
    priority = 5500

    # If we are enforcing, then block (this is the default per the managed rule, so we set the action to none):
    override_action {
      count {}
    }
    #     dynamic "override_action" {
    #       for_each = var.enforce_baseline_rule_set ? [1] : []
    #       content {
    #         none {}
    #       }
    #     }
    #
    #     # If not enforcing, then we are counting:
    #     dynamic "override_action" {
    #       for_each = var.enforce_baseline_rule_set ? [] : [1]
    #       content {
    #         count {}
    #       }
    #     }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "baseline-core-deny-rule"
      sampled_requests_enabled   = false
    }
  }

  # AWS Known Bad Inputs:
  rule {
    # TODO UNCOMMENT BLOCKS LATER
    #     name     = "KnownBadInputs${local.aws_baseline_rule_set_suffix}" # Will either be KnownBadInputsEnforcing or KnownBadInputsPreviewOnly
    name     = "KnownBadInputsPreviewOnly"
    priority = 5501

    override_action {
      count {}
    }

    # If we are enforcing, then block (this is the default per the managed rule, so we set the action to none):
    #     dynamic "override_action" {
    #       for_each = var.enforce_baseline_rule_set ? [1] : []
    #       content {
    #         none {}
    #       }
    #     }
    #
    #     # If not enforcing, then we are counting:
    #     dynamic "override_action" {
    #       for_each = var.enforce_baseline_rule_set ? [] : [1]
    #       content {
    #         count {}
    #       }
    #     }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "baseline-known-bad-inputs-deny-rule"
      sampled_requests_enabled   = false
    }
  }

  # AWS Admin Protection:
  rule {
    name     = "AdminProtectionPreviewOnly" # This one is only in preview for now while we analyze what's going on
    priority = 5502

    # We are only counting this now to check if it breaks anything:
    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAdminProtectionRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "baseline-admin-deny-rule"
      sampled_requests_enabled   = false
    }
  }
  # END AWS MANAGED CORE RULE SET

  # BEGIN ANONYMOUS IP BLOCK:
  dynamic "rule" {
    for_each = var.anonymous_ip_preview == true ? [1] : []
    content {
      name     = "AnonymousIpPreviewOnly"
      priority = 5503

      override_action {
        count {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesAnonymousIpList"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "anonymous-ip-preview-rule"
        sampled_requests_enabled   = false
      }
    }
  }

  dynamic "rule" {
    for_each = var.anonymous_ip_enforcement == true ? [1] : []
    content {
      name     = "AnonymousIpEnforcing"
      priority = 5504

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesAnonymousIpList"
          vendor_name = "AWS"

          # We need to exempt the hosting provider list since this breaks integrations that are cloud hosted:
          rule_action_override {
            action_to_use {
              count {}
            }

            name = "HostingProviderIPList"
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "anonymous-ip-enforcing-rule"
        sampled_requests_enabled   = false
      }
    }
  }
  # END ANONYMOUS IP BLOCK

  # BEGIN AMAZON IP REPUTATION BLOCK:
  dynamic "rule" {
    for_each = var.ip_waf_rule_lists_preview == true ? [1] : []
    content {
      name     = "AmazonIpReputationPreviewOnly"
      priority = 5505

      override_action {
        count {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesAmazonIpReputationList"
          vendor_name = "AWS"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "amz-reputation-preview-rule"
        sampled_requests_enabled   = false
      }
    }
  }

  dynamic "rule" {
    for_each = length(var.ip_waf_rule_lists_enforcement) > 0 ? [1] : []
    content {
      name     = "AmazonIpReputationEnforcing"
      priority = 5506

      # By default, we are going to set these to count. We are going to manually enable for each specific list we want to turn on.
      # We are doing it this way in case AWS adds more; we don't want those to be automatically enforced and potentially break Glean!
      override_action {
        count {}
      }

      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesAmazonIpReputationList"
          vendor_name = "AWS"

          # Only enforce the ones that are specified:
          dynamic "rule_action_override" {
            for_each = var.ip_waf_rule_lists_enforcement
            content {
              action_to_use {
                block {}
              }

              name = rule_action_override.value
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "amz-reputation-enforcing-rule"
        sampled_requests_enabled   = false
      }
    }
  }
  # END AMAZON IP REPUTATION BLOCK

  # TODO: Remove these when ready
  #   # BEGIN SUPPLEMENTAL AWS MANAGED RULES
  #   # Preview:
  #   dynamic "rule" {
  #     for_each = var.supplemental_aws_waf_modules_preview_only
  #
  #     content {
  #       name     = "${rule.value}PreviewOnly"
  #       priority = 5503 + rule.key
  #
  #       override_action {
  #         count {}
  #       }
  #
  #       statement {
  #         managed_rule_group_statement {
  #           name        = local.aws_supplemental_rule_map[rule.value]
  #           vendor_name = "AWS"
  #         }
  #       }
  #
  #       visibility_config {
  #         cloudwatch_metrics_enabled = true
  #         metric_name                = "supplemental-${lower(rule.value)}-preview-rule"
  #         sampled_requests_enabled   = false
  #       }
  #     }
  #   }
  #
  #   # Enforcement:
  #   dynamic "rule" {
  #     for_each = var.supplemental_aws_waf_modules_enforcement
  #
  #     content {
  #       name     = "${rule.value}Enforcing"
  #       priority = 5503 + length(var.supplemental_aws_waf_modules_preview_only) + rule.key
  #
  #       override_action {
  #         none {}
  #       }
  #
  #       statement {
  #         managed_rule_group_statement {
  #           name        = local.aws_supplemental_rule_map[rule.value]
  #           vendor_name = "AWS"
  #         }
  #       }
  #
  #       visibility_config {
  #         cloudwatch_metrics_enabled = true
  #         metric_name                = "supplemental-${lower(rule.value)}-enforce-rule"
  #         sampled_requests_enabled   = false
  #       }
  #     }
  #   }
  #   # END SUPPLEMENTAL AWS MANAGED RULES

  # BEGIN IP RESTRICTION RULES
  rule {
    name     = "ipjc-deny-rule"
    priority = 5300
    statement {
      and_statement {
        statement {
          byte_match_statement {
            positional_constraint = "STARTS_WITH"
            search_string         = "/ipjc/v2"
            text_transformation {
              priority = 0
              type     = "NONE"
            }
            field_to_match {
              uri_path {}
            }
          }
        }
        statement {
          not_statement {
            statement {
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.central_ip_set.arn
              }
            }
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "ipjc-deny-rule"
      sampled_requests_enabled   = false
    }
    action {
      block {}
    }
  }
  dynamic "rule" {
    for_each = aws_wafv2_ip_set.ip_redlist_set
    content {
      name     = "ip-deny-rule"
      priority = 5301
      statement {
        ip_set_reference_statement {
          arn = rule.value.arn
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "ip-deny-rule"
        sampled_requests_enabled   = false
      }
      action {
        block {}
      }
    }
  }
  # END IP RESTRICTION RULES

  # BEGIN USER-AGENT RULES:
  dynamic "rule" {
    for_each = local.block_user_agents_chunks
    content {
      name     = "BlockUserAgentsBatch${rule.key + 1}"
      priority = 5350 + rule.key

      action {
        block {}
      }

      # Make or_statements if the length is > 1 - otherwise just 1 statement.
      statement {
        dynamic "or_statement" {
          for_each = length(rule.value) > 1 ? [1] : []
          content {
            dynamic "statement" {
              for_each = [for val in rule.value : lower(val)]
              content {
                byte_match_statement {
                  field_to_match {
                    single_header {
                      name = "user-agent"
                    }
                  }
                  positional_constraint = "CONTAINS"
                  search_string         = statement.value
                  text_transformation {
                    priority = 0
                    type     = "LOWERCASE"
                  }
                }
              }
            }
          }
        }

        # The singular value statement:
        dynamic "byte_match_statement" {
          for_each = length(rule.value) == 1 ? [1] : []
          content {
            field_to_match {
              single_header {
                name = "user-agent"
              }
            }
            positional_constraint = "CONTAINS"
            search_string         = lower(rule.value[0]) # Single value list
            text_transformation {
              priority = 0
              type     = "LOWERCASE"
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "user-agent-deny-rule"
        sampled_requests_enabled   = false
      }
    }
  }
  # END USER-AGENT RULES

  # BEGIN COUNTRY CODE RULES
  dynamic "rule" {
    for_each = local.country_code_chunks
    content {
      name     = "country-deny-rule-${rule.key}"
      priority = 5400 + rule.key
      statement {
        geo_match_statement {
          country_codes = rule.value
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "country-deny-rule"
        sampled_requests_enabled   = false
      }
      action {
        block {}
      }
    }
  }
  # END COUNTRY CODE RULES

  # BEGIN IP GREEN LISTING RULES
  # Rule for admin:
  dynamic "rule" {
    for_each = aws_wafv2_ip_set.ip_greenlist_set
    content {
      name     = "ip-greenlist-rule-admin"
      priority = 5700
      statement {
        and_statement {
          statement {
            byte_match_statement {
              positional_constraint = "CONTAINS"
              field_to_match {
                uri_path {}
              }
              search_string = "/admin"
              text_transformation {
                priority = 0
                type     = "LOWERCASE"
              }
            }
          }
          statement {
            not_statement {
              statement {
                ip_set_reference_statement {
                  arn = rule.value.arn
                }
              }
            }
          }
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "ip-greenlist-rule-admin"
        sampled_requests_enabled   = false
      }
      action {
        block {}
      }
    }
  }

  # Rule for QE /rest/api:
  dynamic "rule" {
    for_each = aws_wafv2_ip_set.ip_greenlist_set
    content {
      name     = "ip-greenlist-rule-qe-rest-api"
      priority = 5701
      statement {
        and_statement {
          statement {
            byte_match_statement {
              positional_constraint = "CONTAINS"
              field_to_match {
                uri_path {}
              }
              search_string = "/rest/api"
              text_transformation {
                priority = 0
                type     = "LOWERCASE"
              }
            }
          }
          statement {
            not_statement {
              statement {
                ip_set_reference_statement {
                  arn = rule.value.arn
                }
              }
            }
          }
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "ip-greenlist-rule-qe-rest-api"
        sampled_requests_enabled   = false
      }
      action {
        block {}
      }
    }
  }
  # END IP GREEN LISTING RULES

  # BEGIN THROTTLING RULES
  # Note: unfortunately terraform doesn't let you configure the window for throttling - it's always 5 minutes
  rule {
    name     = "throttle-autocomplete-requests"
    priority = 6000
    statement {
      rate_based_statement {
        limit              = var.autocomplete_rate_limiting_count
        aggregate_key_type = "CONSTANT"
        scope_down_statement {
          byte_match_statement {
            positional_constraint = "STARTS_WITH"
            search_string         = "/api/v1/autocomplete"
            text_transformation {
              priority = 0
              type     = "NONE"
            }
            field_to_match {
              uri_path {}
            }
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "autocomplete-throttle-rule"
      sampled_requests_enabled   = false
    }
    action {
      block {}
    }
  }
  rule {
    name     = "throttle-ask-requests"
    priority = 6001
    statement {
      rate_based_statement {
        limit              = var.ask_rate_limiting_count
        aggregate_key_type = "CONSTANT"
        scope_down_statement {
          byte_match_statement {
            positional_constraint = "STARTS_WITH"
            search_string         = "/api/v1/ask"
            text_transformation {
              priority = 0
              type     = "NONE"
            }
            field_to_match {
              uri_path {}
            }
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "ask-throttle-rule"
      sampled_requests_enabled   = false
    }
    action {
      block {}
    }
  }
  rule {
    name     = "throttle-search-requests"
    priority = 6002
    statement {
      rate_based_statement {
        limit              = var.search_rate_limiting_count
        aggregate_key_type = "CONSTANT"
        scope_down_statement {
          byte_match_statement {
            positional_constraint = "STARTS_WITH"
            search_string         = "/api/v1/search"
            text_transformation {
              priority = 0
              type     = "NONE"
            }
            field_to_match {
              uri_path {}
            }
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "search-throttle-rule"
      sampled_requests_enabled   = false
    }
    action {
      block {}
    }
  }
  rule {
    name     = "throttle-actas-requests"
    priority = 6003
    statement {
      rate_based_statement {
        limit              = var.actas_rate_limiting_count
        aggregate_key_type = "CONSTANT"
        scope_down_statement {
          byte_match_statement {
            positional_constraint = "CONTAINS"
            search_string         = "Actas-Token"
            text_transformation {
              priority = 0
              type     = "NONE"
            }
            field_to_match {
              single_header {
                name = "cookie"
              }
            }
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "actas-throttle-rule"
      sampled_requests_enabled   = false
    }
    action {
      block {}
    }
  }
  rule {
    name     = "throttle-glean-debug-requests"
    priority = 6004
    statement {
      rate_based_statement {
        limit              = var.debug_rate_limiting_count
        aggregate_key_type = "CONSTANT"
        scope_down_statement {
          byte_match_statement {
            positional_constraint = "STARTS_WITH"
            search_string         = "/ipjc/v2/debug"
            text_transformation {
              priority = 0
              type     = "NONE"
            }
            field_to_match {
              uri_path {}
            }
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "glean-debug-throttle-rule"
      sampled_requests_enabled   = false
    }
    action {
      block {}
    }
  }
  # END THROTTLING RULES
  # BEGIN CUSTOM RULES FOR UGC BLOCKING (aws-scio-prod only)
  custom_response_body {
    content      = "UGC writes are intentionally blocked by the Glean firewall"
    content_type = "TEXT_PLAIN"
    key          = "ugc-write-deny"
  }
  dynamic "rule" {
    for_each = var.block-ugc-write-endpoints ? [1] : []
    content {
      name     = "ugc-write-deny-rule"
      priority = 7000
      statement {
        regex_pattern_set_reference_statement {
          arn = aws_wafv2_regex_pattern_set.ugc_write_regex_pattern_set.arn
          text_transformation {
            priority = 0
            type     = "NONE"
          }
          field_to_match {
            uri_path {}
          }
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "ugc-write-deny-rule"
        sampled_requests_enabled   = false
      }
      action {
        block {
          custom_response {
            response_code            = 403
            custom_response_body_key = "ugc-write-deny"
          }
        }
      }
    }
  }
  # END CUSTOM RULES FOR UGC BLOCKING (aws-scio-prod only)
}

resource "aws_cloudwatch_log_group" "aws_waf_logs_glean" {
  # name must start with `aws-waf-logs-`
  name              = "aws-waf-logs-glean"
  retention_in_days = 90
}

resource "aws_wafv2_web_acl_logging_configuration" "glean_waf_logging_config" {
  log_destination_configs = [aws_cloudwatch_log_group.aws_waf_logs_glean.arn]
  resource_arn            = aws_wafv2_web_acl.glean_waf.arn
  redacted_fields {
    // redact auth header to not leak tokens
    single_header {
      name = "authorization"
    }
  }
}
