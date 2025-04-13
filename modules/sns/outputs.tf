output "sns_arns" {
  value = { for k, sns in aws_sns_topic.sns : k => sns.arn }
}
