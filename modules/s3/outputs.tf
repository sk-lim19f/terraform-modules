output "s3_arns" {
  value       = { for k, s3 in aws_s3_bucket.bucket : k => s3.arn }
}

output "s3_buckets" {
  value       = { for k, s3 in aws_s3_bucket.bucket : k => s3.bucket }
}

output "s3_ids" {
  value       = { for k, s3 in aws_s3_bucket.bucket : k => s3.id }
}