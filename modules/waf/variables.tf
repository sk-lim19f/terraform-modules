variable "waf_web_acl" {
  type = map(object({
    web_acl_name = string
    scope        = string

    visibility_config = object({
      cloudwatch_metrics_enabled = bool
      sampled_requests_enabled   = bool
    })

    rule_ip = map(object({
      name     = string
      priority = number

      action = string

      ip_set_reference_statement = optional(map(object({
        ip_set_key = string
      })))

      visibility_config = object({
        metric_name                = string
        cloudwatch_metrics_enabled = bool
        sampled_requests_enabled   = bool
      })

      rule_label = optional(object({
        name = string
      }))
    }))

    rule_managed = map(object({
      name     = string
      priority = number

      managed_rule_group_statement = optional(map(object({
        managed_rule_name = string
        vendor_name       = string

        rule_action_override = optional(list(object({
          name   = string
          action = string
        })), [])
      })))

      visibility_config = object({
        metric_name                = string
        cloudwatch_metrics_enabled = bool
        sampled_requests_enabled   = bool
      })

      rule_label = optional(object({
        name = string
      }))
    }))

    rule_geo = map(object({
      name     = string
      priority = number

      geo_match_statement = optional(map(object({
        country_codes = list(string)
      })))

      visibility_config = object({
        metric_name                = string
        cloudwatch_metrics_enabled = bool
        sampled_requests_enabled   = bool
      })

      rule_label = optional(object({
        name = string
      }))
    }))
  }))
}

variable "ip_set" {
  type = map(object({
    name         = string
    scope        = string
    description  = string
    ip_addresses = optional(list(string))
  }))
}
