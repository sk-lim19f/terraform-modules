output "cloudfront_distribution_domain_name" {
  value       = { for k, cloudfront_distribution in aws_cloudfront_distribution.cloudfront_distribution : k => cloudfront_distribution.domain_name }
}

output "cloudfront_public_key_id" {
  value       = { for k, cloudfront_public_key in aws_cloudfront_public_key.cloudfront_public_key : k => cloudfront_public_key.id }
}