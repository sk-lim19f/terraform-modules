output "db_instance_endpoint" {
  value       = aws_db_instance.rds.endpoint
}

output "db_instance_id" {
  value       = aws_db_instance.rds.id
}
