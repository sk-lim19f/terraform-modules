resource "aws_cloudwatch_event_rule" "eventbridge" {
  for_each = var.eventbridge

  name                = each.value.name
  description         = each.value.description
  event_pattern       = try(each.value.event_pattern, null)
  schedule_expression = try(each.value.schedule_expression, null)
}

resource "aws_cloudwatch_event_target" "eventbridge_target" {
  for_each = var.eventbridge_target

  target_id = each.value.target_id
  rule      = aws_cloudwatch_event_rule.eventbridge[each.value.rule_key].name
  arn       = each.value.target_arn
}
