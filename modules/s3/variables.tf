variable "environment" {
  type = string
}

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

variable "s3_bucket_website_configuration" {
  type = map(object({
    bucket_key = string

    index_document = object({
      value = string
    })

    error_document = object({
      value = string
    })
  }))
}

variable "s3_bucket_policy" {
  type = map(object({
    bucket_key = string
    policy     = string
  }))
}
