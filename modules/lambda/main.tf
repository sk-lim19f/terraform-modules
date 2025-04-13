resource "aws_lambda_function" "lambda" {
  for_each = var.lambda

  function_name = each.value.function_name
  role          = each.value.iam_role_arn
  handler       = each.value.handler
  runtime       = each.value.runtime
  memory_size   = each.value.memory_size
  timeout       = each.value.timeout

  layers = [aws_lambda_layer_version.lambda_layer[each.value.layer_key].arn]

  s3_bucket = each.value.s3_bucket_key
  s3_key    = aws_s3_object.lambda_package[each.value.s3_object_key].key

  vpc_config {
    security_group_ids = each.value.vpc_config.security_group_ids
    subnet_ids         = each.value.vpc_config.subnet_ids
  }

  environment {
    variables = each.value.variables
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_lambda_layer_version" "lambda_layer" {
  for_each = var.lambda_layer

  layer_name          = each.value.name
  description         = each.value.description
  compatible_runtimes = each.value.compatible_runtimes
  filename            = each.value.filename

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_s3_object" "lambda_package" {
  for_each = var.lambda_package

  bucket       = each.value.bucket
  key          = each.value.file_name
  source       = each.value.source_dir
  content_type = each.value.content_type
}

resource "aws_lambda_permission" "lambda_permission" {
  for_each = var.lambda_permission

  statement_id  = each.value.statement_id
  action        = each.value.action
  function_name = aws_lambda_function.lambda[each.value.lambda_key].function_name
  principal     = each.value.principal
  source_arn    = each.value.eventbridge_rule_arn
}
