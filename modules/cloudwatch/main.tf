resource "aws_cloudwatch_log_group" "log_group" {
  for_each = var.log_group

  name = each.value.name
}

resource "aws_cloudwatch_log_resource_policy" "logging_policy" {
  for_each = var.logging_policy

  policy_document = each.value.policy_document
  policy_name     = each.value.policy_name
}
