resource "aws_cloudwatch_log_group" "log_group" {
  for_each = var.log_group

  name = each.value.name
}

resource "aws_cloudwatch_metric_alarm" "cloudwatch_alarm_standard" {
  for_each = { for k, v in var.cloudwatch_alarm : k => v if v.metric_query == null }

  alarm_name          = each.value.alarm_name
  alarm_description   = each.value.alarm_description
  namespace           = try(each.value.namespace, null)
  metric_name         = try(each.value.metric_name, null)
  statistic           = try(each.value.statistic, null)
  evaluation_periods  = try(each.value.evaluation_periods, null)
  period              = try(each.value.period, null)
  threshold           = try(each.value.threshold, null)
  comparison_operator = try(each.value.comparison_operator, null)
  dimensions          = try(each.value.dimensions, {})

  alarm_actions = each.value.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "cloudwatch_alarm_metric_math" {
  for_each = { for k, v in var.cloudwatch_alarm : k => v if v.metric_query != null }

  alarm_name          = each.value.alarm_name
  alarm_description   = each.value.alarm_description
  evaluation_periods  = try(each.value.evaluation_periods, null)
  comparison_operator = try(each.value.comparison_operator, null)
  threshold           = try(each.value.threshold, null)

  dynamic "metric_query" {
    for_each = each.value.metric_query
    content {
      id          = metric_query.value.id
      return_data = try(metric_query.value.return_data, false)
      expression  = try(metric_query.value.expression, null)
      label       = try(metric_query.value.label, null)

      dynamic "metric" {
        for_each = metric_query.value.metric != null ? [metric_query.value.metric] : []
        content {
          namespace   = try(metric.value.namespace, null)
          metric_name = try(metric.value.metric_name, null)
          period      = try(metric.value.period, null)
          stat        = try(metric.value.stat, null)
          dimensions  = try(metric.value.dimensions, null)
        }
      }
    }
  }

  alarm_actions = each.value.alarm_actions
}

resource "aws_cloudwatch_log_resource_policy" "logging_policy" {
  for_each = var.logging_policy

  policy_document = each.value.policy_document
  policy_name     = each.value.policy_name
}
