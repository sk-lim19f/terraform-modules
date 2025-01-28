variable "s3_buckets" {
  type = map(object({
    product          = string
    service          = string
    key              = optional(string)
    lifecycle_status = optional(string)

    lifecycle = optional(object({
      prefix = optional(string)
      key    = optional(string)
      value  = optional(string)
      days   = optional(number)
    }))
  }))
}

variable "environment" {
  type = string
}
