variable "environment" {
  type = string
}

variable "alb_configs" {
  type = map(object({
    product             = string
    service             = string
    internal            = bool
    subnets             = list(string)
    alb_security_groups = list(string)
    idle_timeout        = number
  }))
}

variable "target_groups" {
  type = map(object({
    product               = string
    service               = string
    alb                   = string
    port                  = number
    protocol              = string
    target_type           = string
    vpc_id                = string
    health_check_interval = number
    healthy_threshold     = number
    unhealthy_threshold   = number
    health_check_timeout  = number
    health_check_matcher  = string
    health_check_path     = string
  }))
}

variable "listener_http" {
  type = map(object({
    alb                       = string
    tg                        = optional(string)
    port                      = optional(number)
    protocol                  = optional(string)
    default_http_action_type  = optional(string)
    redirect_http_port        = optional(number)
    redirect_http_protocol    = optional(string)
    redirect_http_status_code = optional(string)
  }))
}

variable "listener_https" {
  type = map(object({
    alb                       = string
    tg                        = optional(string)
    port                      = optional(number)
    protocol                  = optional(string)
    ssl_policy                = optional(string)
    ssl_certificate_arn       = string
    default_https_action_type = optional(string)

    default_action = optional(object({
      target_groups = map(object({
        tg_key = string
        weight = number
      }))
    }), null)
  }))
}

variable "listener_rules" {
  type = map(object({
    name               = string
    listener           = string
    priority           = number
    tg                 = string
    host_header_values = optional(list(string), [])
  }))
}
