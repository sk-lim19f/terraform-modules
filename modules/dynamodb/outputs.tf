output "dynamodb_table_arn" {
  value       = { for k, dynamodb in aws_dynamodb_table.dynamodb_table : k => dynamodb.arn }
}