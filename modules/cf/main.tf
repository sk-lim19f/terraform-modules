resource "aws_cloudfront_origin_access_control" "oac" {
  for_each = var.oac

  name                              = "OAC-for-${each.value.name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  for_each = var.cloudfront_distribution

  comment             = each.value.comment
  default_root_object = try(each.value.root_object, null)
  aliases             = try(each.value.aliases, [])
  enabled             = true
  is_ipv6_enabled     = true

  dynamic "origin" {
    for_each = each.value.origin != null ? each.value.origin : {}
    iterator = origin

    content {
      domain_name              = "${origin.value.bucket_name}.s3.ap-northeast-2.amazonaws.com"
      origin_id                = "S3-${origin.value.bucket_name}"
      origin_access_control_id = aws_cloudfront_origin_access_control.oac[each.value.oac_id].id
    }
  }

  default_cache_behavior {
    target_origin_id = "S3-${each.value.bucket_name}"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
    origin_request_policy_id   = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # Managed-CORS-S3Origin
    response_headers_policy_id = try(aws_cloudfront_response_headers_policy.response_headers_policy[each.value.response_headers_policy].id, "5cc3b908-e619-4b99-88e5-2cf7f45965bd")

    viewer_protocol_policy = "redirect-to-https"
  }

  dynamic "ordered_cache_behavior" {
    for_each = each.value.path_pattern_behavior != null ? each.value.path_pattern_behavior : {}
    iterator = path_pattern_behavior

    content {
      target_origin_id = "S3-${path_pattern_behavior.value.bucket_name}"
      path_pattern     = path_pattern_behavior.value.path_pattern

      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]

      cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
      origin_request_policy_id   = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # Managed-CORS-S3Origin
      response_headers_policy_id = "5cc3b908-e619-4b99-88e5-2cf7f45965bd" # Managed-CORS-With-Preflight
      trusted_key_groups = try([
        aws_cloudfront_key_group.cloudfront_key_group[path_pattern_behavior.value.key_group_id].id
      ], [])

      viewer_protocol_policy = "redirect-to-https"
    }
  }

  dynamic "custom_error_response" {
    for_each = each.value.custom_error_response != null ? each.value.custom_error_response : {}
    content {
      error_code         = custom_error_response.value.error_code
      response_code      = 200
      response_page_path = custom_error_response.value.response_page_path
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # lifecycle {
  #   ignore_changes = [
  #     default_cache_behavior,
  #     ordered_cache_behavior,
  #     viewer_certificate
  #   ]
  # }

  lifecycle {
    ignore_changes = all
  }

  tags = {
    Name = "CloudFront for ${each.key}"
    ENV  = var.environment
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  for_each = var.bucket_policy

  bucket = each.value.bucket_name
  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "cloudfront.amazonaws.com"
        },
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::${each.value.bucket_name}/*",
        "Condition": {
          "StringEquals": {
            "AWS:SourceArn": "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.cloudfront_distribution[each.value.distribution].id}"
          }
        }
      }
    ]
  }
  POLICY
}

resource "aws_cloudfront_response_headers_policy" "response_headers_policy" {
  for_each = var.response_headers_policy

  name = each.value.name

  dynamic "cors_config" {
    for_each = each.value.cors_config != null ? [each.value.cors_config] : []

    content {
      access_control_allow_credentials = false

      access_control_allow_methods {
        items = cors_config.value.allow_methods
      }

      access_control_allow_headers {
        items = cors_config.value.allow_headers
      }

      access_control_allow_origins {
        items = cors_config.value.allow_origins
      }

      origin_override = false
    }
  }

  dynamic "custom_headers_config" {
    for_each = each.value.custom_headers_config != null ? each.value.custom_headers_config : {}

    content {
      items {
        header   = custom_headers_config.value.header
        value    = custom_headers_config.value.value
        override = custom_headers_config.value.override
      }
    }
  }
}

resource "aws_cloudfront_public_key" "cloudfront_public_key" {
  for_each = var.cloudfront_public_key

  name        = each.value.name
  comment     = each.value.comment
  encoded_key = each.value.encoded_key
}

resource "aws_cloudfront_key_group" "cloudfront_key_group" {
  for_each = var.cloudfront_key_group

  name  = each.value.name
  items = [aws_cloudfront_public_key.cloudfront_public_key[each.value.key_id].id]
}
