variable "iam_role" {
  type = map(object({
    name    = string
    service = string
  }))
}

variable "iam_instance_profile" {
  type = map(object({
    name     = string
    role_key = string
  }))
}

variable "iam_policy" {
  type = map(object({
    name   = string
    policy = string
  }))
}

variable "iam_role_policy_attachment" {
  type = map(object({
    role_key   = string
    policy_key = optional(string, null)
    policy_arn = optional(string, null)
  }))
}
