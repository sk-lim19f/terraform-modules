variable "eventbridge" {
  type = map(object({
    name                = string
    description         = string
    event_pattern       = optional(string)
    schedule_expression = optional(string)
  }))
}

variable "eventbridge_target" {
  type = map(object({
    target_id  = string
    rule_key   = string
    target_arn = string
  }))
}
