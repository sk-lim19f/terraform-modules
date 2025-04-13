output "db_instance_endpoint" {
  value       = { for k, rds in aws_db_instance.rds : k => rds.endpoint }
}

output "db_instance_id" {
  value       = { for k, rds in aws_db_instance.rds : k => rds.id }
}
