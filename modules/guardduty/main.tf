resource "aws_guardduty_malware_protection_plan" "word_s3_malware" {
  for_each = var.guardduty_malware_protection

  role     = each.value.iam_arn

  protected_resource {
    s3_bucket {
      bucket_name = each.value.s3_id
    }
  }

  actions {
    tagging {
      status = "ENABLED"
    }
  }

  tags = {
    Name = "${each.value.s3_id}-malware-protection"
  }
}
