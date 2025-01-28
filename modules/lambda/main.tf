resource "aws_lambda_function" "lambda" {
  for_each = var.lambda

  function_name = each.value.function_name
  role          = each.value.iam_role_arn
  handler       = each.value.handler
  runtime       = each.value.runtime
  timeout       = each.value.timeout

  s3_bucket = each.value.s3_bucket_key
  s3_key    = aws_s3_object.lambda_package[each.value.s3_object_key].key

  vpc_config {
    security_group_ids = each.value.vpc_config.security_group_ids
    subnet_ids         = each.value.vpc_config.subnet_ids
  }

  environment {
      variables = each.value.variables
  }
}

resource "aws_s3_object" "lambda_package" {
  for_each = var.lambda_package

  bucket = each.value.bucket
  key    = each.value.jar_file_name
  source = each.value.source_dir
  content_type = "application/java-archive"
}
