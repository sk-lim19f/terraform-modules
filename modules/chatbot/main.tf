resource "aws_chatbot_slack_channel_configuration" "slack_chatbot" {
  for_each = var.slack_chatbot

  configuration_name = each.value.name
  slack_team_id      = each.value.slack_workspace_id
  slack_channel_id   = each.value.slack_channel_id
  iam_role_arn       = each.value.iam_role_arn
  sns_topic_arns     = each.value.sns_topic_arns

  tags = {
    Name = each.value.name
  }
}
