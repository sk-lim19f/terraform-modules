variable "oac" {
  type = map(object({
    name = string
  }))
}

variable "cloudfront_distribution" {
  type = map(object({
    comment     = optional(string)
    root_object = optional(string)
    aliases     = optional(list(string))
    oac_id      = string

    origin = map(object({
      bucket_name = string
    }))

    bucket_name             = string
    response_headers_policy = optional(string)

    path_pattern_behavior = optional(map(object({
      bucket_name  = string
      path_pattern = string
      key_group_id = optional(string)
    })))

    custom_error_response = optional(map(object({
      error_code         = number
      response_page_path = string
    })))
  }))
}

variable "bucket_policy" {
  type = map(object({
    bucket_name  = string
    distribution = string
  }))
}

variable "environment" {
  type = string
}

variable "response_headers_policy" {
  type = map(object({
    name = string

    cors_config = optional(object({
      allow_headers = list(string)
      allow_methods = list(string)
      allow_origins = list(string)
    }))

    custom_headers_config = optional(map(object({
      header   = string
      value    = string
      override = bool
    })))
  }))
}

variable "cloudfront_public_key" {
  type = map(object({
    name        = string
    comment     = string
    encoded_key = string
  }))
}

variable "cloudfront_key_group" {
  type = map(object({
    name   = string
    key_id = string
  }))
}
