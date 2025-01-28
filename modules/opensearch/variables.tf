variable "environment" {
  type = string
}

variable "search_engine_domain" {
  type = map(object({
    domain_name    = string
    engine_version = string

    vpc_options = object({
      subnet_ids = list(string)
      sg_ids     = list(string)
    })

    advanced_security_options = object({
      master_user_name     = string
      master_user_password = string
    })

    cluster_config = object({
      instance_type  = string
      instance_count = number

      multiple_az_enabled = optional(bool)

      zone_awareness_config = optional(object({
        az_count = number
      }))

      master_enabled = bool
      master_type    = optional(string)
      master_count   = optional(number)

      warm_enabled = bool
      warm_type    = optional(string)
      warm_count   = optional(number)
    })

    timeouts = optional(object({
      create = string
      delete = string
    }))

    ebs_options = object({
      ebs_enabled = bool
      volume_size = number
      volume_type = string
    })

    domain_endpoint_options = object({
      custom_endpoint                 = string
      custom_endpoint_certificate_arn = string
    })

    auto_tune_options = optional(object({
      state               = optional(string)
      rollback_on_disable = optional(string)
      off_peak            = optional(string)

      maintenance_schedules = optional(object({
        cron_expression_for_recurrence = optional(string)
        start_at                       = optional(string)

        duration = optional(object({
          unit  = optional(string)
          value = optional(number)
        }))
      }))
    }))

    snapshot_options = object({
      snapshot_hour = number
    })

    log_publishing_options = map(object({
      enabled                  = bool
      cloudwatch_log_group_arn = string
      log_type                 = string
    }))
  }))
}

variable "search_engine_package_association" {
  type = map(object({
    domain_key = string
    package_id = string
  }))
}

variable "search_engine_policy" {
  type = map(object({
    domain_key      = string
    access_policies = string
  }))
}
