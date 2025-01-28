variable "lambda" {
  type = map(object({
    function_name = string
    iam_role_arn  = string
    handler       = string
    runtime       = string
    timeout       = number

    s3_bucket_key = string
    s3_object_key = string

    vpc_config = object({
      security_group_ids = list(string)
      subnet_ids        = list(string)
    })

    variables = map(string)
  }))
}

variable "lambda_package" {
  type = map(object({
    bucket        = string
    jar_file_name = string
    source_dir    = string
  }))
}
