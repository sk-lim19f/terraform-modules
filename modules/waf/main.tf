terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_wafv2_web_acl" "waf_web_acl" {
  for_each = var.waf_web_acl

  name  = each.value.web_acl_name
  scope = each.value.scope

  default_action {
    allow {}
  }

  visibility_config {
    metric_name                = each.value.web_acl_name
    cloudwatch_metrics_enabled = each.value.visibility_config.cloudwatch_metrics_enabled
    sampled_requests_enabled   = each.value.visibility_config.sampled_requests_enabled
  }

  # AWS Managed Rule
  dynamic "rule" {
    for_each = each.value.rule_managed

    content {
      name     = rule.value.name
      priority = rule.value.priority

      override_action {
        none {}
      }

      statement {
        dynamic "managed_rule_group_statement" {
          for_each = rule.value.managed_rule_group_statement != null ? rule.value.managed_rule_group_statement : {}

          content {
            name        = managed_rule_group_statement.value.managed_rule_name
            vendor_name = managed_rule_group_statement.value.vendor_name

            dynamic "rule_action_override" {
              for_each = lookup(managed_rule_group_statement.value, "rule_action_override", [], )
              # for_each = try(managed_rule_group_statement.value.rule_action_override, [])

              content {
                name = rule_action_override.value.name

                dynamic "action_to_use" {
                  for_each = rule_action_override.value.action == "block" ? [1] : []
                  content {
                    block {}
                  }
                }

                dynamic "action_to_use" {
                  for_each = rule_action_override.value.action == "allow" ? [1] : []
                  content {
                    allow {}
                  }
                }

                dynamic "action_to_use" {
                  for_each = rule_action_override.value.action == "count" ? [1] : []
                  content {
                    count {}
                  }
                }
              }
            }
          }
        }
      }

      visibility_config {
        metric_name                = rule.value.visibility_config.metric_name
        cloudwatch_metrics_enabled = rule.value.visibility_config.cloudwatch_metrics_enabled
        sampled_requests_enabled   = rule.value.visibility_config.sampled_requests_enabled
      }

      dynamic "rule_label" {
        for_each = rule.value.rule_label != null ? rule.value.rule_label : {}

        content {
          name = try(rule.value.rule_label.name, null)
        }
      }
    }
  }

  # IP Based Rule
  dynamic "rule" {
    for_each = each.value.rule_ip

    content {
      name     = rule.value.name
      priority = rule.value.priority

      dynamic "action" {
        for_each = rule.value.action == "allow" ? [1] : []
        content {
          allow {}
        }
      }

      dynamic "action" {
        for_each = rule.value.action == "block" ? [1] : []
        content {
          block {}
        }
      }

      # action {
      #   allow {}
      # }

      statement {
        dynamic "ip_set_reference_statement" {
          for_each = rule.value.ip_set_reference_statement != null ? rule.value.ip_set_reference_statement : {}

          content {
            arn = aws_wafv2_ip_set.ip_set[ip_set_reference_statement.value.ip_set_key].arn
          }
        }
      }

      visibility_config {
        metric_name                = rule.value.visibility_config.metric_name
        cloudwatch_metrics_enabled = rule.value.visibility_config.cloudwatch_metrics_enabled
        sampled_requests_enabled   = rule.value.visibility_config.sampled_requests_enabled
      }

      dynamic "rule_label" {
        for_each = rule.value.rule_label != null ? rule.value.rule_label : {}

        content {
          name = try(rule.value.rule_label.name, null)
        }
      }
    }
  }


  # Geo Based Rule
  dynamic "rule" {
    for_each = each.value.rule_geo

    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        block {}
      }

      statement {
        dynamic "geo_match_statement" {
          for_each = rule.value.geo_match_statement != null ? rule.value.geo_match_statement : {}

          content {
            country_codes = geo_match_statement.value.country_codes
          }
        }
      }

      visibility_config {
        metric_name                = rule.value.visibility_config.metric_name
        cloudwatch_metrics_enabled = rule.value.visibility_config.cloudwatch_metrics_enabled
        sampled_requests_enabled   = rule.value.visibility_config.sampled_requests_enabled
      }

      dynamic "rule_label" {
        for_each = rule.value.rule_label != null ? rule.value.rule_label : {}

        content {
          name = try(rule.value.rule_label.name, null)
        }
      }
    }
  }
}

resource "aws_wafv2_ip_set" "ip_set" {
  for_each = var.ip_set

  name               = try(each.value.name, null)
  scope              = try(each.value.scope, null)
  description        = try(each.value.description, null)
  ip_address_version = "IPV4"

  addresses = try(each.value.ip_addresses, [])

  lifecycle {
    ignore_changes = all
  }
}
