variable "oac" {
  type = map(object({
    name = string
  }))
}

variable "cloudfront_distribution" {
  type = map(object({
    bucket_name = string
    comment     = string
    oac_id      = string
    root_object = string

    custom_error_response = map(object({
      error_code         = number
      response_page_path = string
    }))
  }))
}

variable "cloudfront_distribution_path_pattern" {
  type = map(object({
    bucket_name = string
    comment     = string
  }))
}

variable "cloudfront_origins" {
  type = map(object({
    bucket_name  = string
    path_pattern = optional(string)
    oac_id       = string
    distribution = string
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
