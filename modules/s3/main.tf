resource "aws_s3_bucket" "bucket" {
  for_each = var.s3_buckets

  bucket        = lower("${var.environment}-${each.value.product}-${each.value.service}-s3")
  force_destroy = true

  tags = {
    Name    = lower("${var.environment}-${each.value.product}-${each.value.service}-s3")
    ENV     = var.environment
    Product = each.value.product
    Service = each.value.service
  }
}

resource "aws_s3_object" "set_prefix" {
  for_each = {
    for k, v in var.s3_buckets : k => v if v.key != null
  }

  bucket  = aws_s3_bucket.bucket[each.key].id
  key     = try(each.value.key, null)
  content = ""
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  for_each = {
    for k, v in var.s3_buckets : k => v
    if lookup(v, "lifecycle_status", "") == "Enabled"
  }

  bucket = aws_s3_bucket.bucket[each.key].bucket

  rule {
    id     = "expire-all-objects"
    status = "Enabled"

    filter {
      prefix = lookup(each.value.lifecycle, "prefix", "")

      dynamic "tag" {
        for_each = (lookup(each.value.lifecycle, "key", null) != null && lookup(each.value.lifecycle, "value", null) != null) ? [1] : []
        content {
          key   = each.value.lifecycle.key
          value = each.value.lifecycle.value
        }
      }
    }

    expiration {
      days = lookup(each.value.lifecycle, "days", 30)
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  for_each = var.s3_buckets

  bucket = aws_s3_bucket.bucket[each.key].bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
