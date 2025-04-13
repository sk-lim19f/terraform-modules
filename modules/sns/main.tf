resource "aws_sns_topic" "sns" {
  for_each = var.sns

  name = lower("${each.value.name}-topic")
}

