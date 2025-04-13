output "ecr_urls" {
  value = { for k, ecr in aws_ecr_repository.ecr_repository : k => ecr.repository_url }
}
