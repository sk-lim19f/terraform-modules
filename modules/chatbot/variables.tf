variable "slack_chatbot" {
  type = map(object({
    name               = string
    iam_role_arn       = string
    slack_workspace_id = string
    slack_channel_id   = string
    sns_topic_arns     = list(string)
  }))
}
