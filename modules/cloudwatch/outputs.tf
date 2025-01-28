output "log_group_arn" {
  value       = { for k, log_group in aws_cloudwatch_log_group.log_group : k => log_group.arn }
}