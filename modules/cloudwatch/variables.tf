variable "log_group" {
  type = map(object({
    name = string
  }))
}

variable "logging_policy" {
  type = map(object({
    policy_document = string
    policy_name     = string
  }))
}

variable "cloudwatch_alarm" {
  type = map(object({
    alarm_name        = string
    alarm_description = string

    namespace           = optional(string)
    metric_name         = optional(string)
    statistic           = optional(string)
    evaluation_periods  = optional(number)
    period              = optional(number)
    threshold           = optional(number)
    comparison_operator = optional(string)
    dimensions          = optional(map(string))

    metric_query = optional(list(object({
      id          = optional(string)
      return_data = optional(bool)
      expression  = optional(string)
      label       = optional(string)

      metric = optional(object({
        namespace   = optional(string)
        metric_name = optional(string)
        period      = optional(number)
        stat        = optional(string)
        dimensions  = optional(map(string))
      }))
    })))

    alarm_actions = list(string)
  }))
}
