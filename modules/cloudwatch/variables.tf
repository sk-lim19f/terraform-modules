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
