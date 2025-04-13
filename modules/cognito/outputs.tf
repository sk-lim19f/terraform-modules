output "cognito_user_pool_arn" {
  value       = { for k, user_pool in aws_cognito_user_pool.cognito_user_pool : k => user_pool.arn }
}