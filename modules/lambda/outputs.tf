output "lambda_function_arn" {
  value       = { for k, lambda in aws_lambda_function.lambda : k => lambda.arn }
}

output "lambda_function_name" {
  value       = { for k, lambda in aws_lambda_function.lambda : k => lambda.function_name }
}
