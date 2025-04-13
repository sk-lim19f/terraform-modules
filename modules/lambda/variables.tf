variable "lambda" {
  type = map(object({
    function_name = string
    iam_role_arn  = string
    handler       = string
    runtime       = string
    memory_size   = number
    timeout       = number

    layer_key = optional(string)

    s3_bucket_key = string
    s3_object_key = string

    vpc_config = object({
      security_group_ids = list(string)
      subnet_ids         = list(string)
    })

    variables = map(string)
  }))
}

variable "lambda_layer" {
  type = map(object({
    name                = string
    description         = string
    compatible_runtimes = list(string)
    filename            = string
  }))
}

variable "lambda_package" {
  type = map(object({
    bucket       = string
    file_name    = string
    source_dir   = string
    content_type = string
  }))
}

variable "lambda_permission" {
  type = map(object({
    statement_id         = string
    action               = string
    lambda_key           = string
    principal            = string
    eventbridge_rule_arn = string
  }))
}
