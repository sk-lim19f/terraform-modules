output "eventbridge_rule_arns" {
  value = { for k, eventbridge in aws_cloudwatch_event_rule.eventbridge : k => eventbridge.arn }
}
