variable "guardduty_malware_protection" {
  type = map(object({
    s3_id   = string
    iam_arn = string
  }))
}
