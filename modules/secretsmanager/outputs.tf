output "secret_manager_secret_arn" {
  value       = { for k, secretsmanager_secret in aws_secretsmanager_secret.secretsmanager_secret : k => secretsmanager_secret.arn }
}

output "secret_manager_secret_name" {
  value       = { for k, secretsmanager_secret in aws_secretsmanager_secret.secretsmanager_secret : k => secretsmanager_secret.name }
}

output "secret_manager_secret_id" {
  value       = { for k, secretsmanager_secret in aws_secretsmanager_secret.secretsmanager_secret : k => secretsmanager_secret.id }
}
