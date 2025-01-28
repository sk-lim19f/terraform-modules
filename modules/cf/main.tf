# CloudFront Origin Access Control (OAC)
resource "aws_cloudfront_origin_access_control" "oac" {
  for_each = var.oac

  name                              = "OAC-for-${each.value.name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cdn_web" {
  for_each = var.cloudfront_distribution

  comment             = each.value.comment
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = try(each.value.root_object, null)

  origin {
    domain_name              = "${each.value.bucket_name}.s3.ap-northeast-2.amazonaws.com"
    origin_id                = "S3-${each.value.bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac[each.value.oac_id].id
  }

  default_cache_behavior {
    target_origin_id = "S3-${each.value.bucket_name}"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
    origin_request_policy_id   = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # Managed-CORS-S3Origin
    response_headers_policy_id = "5cc3b908-e619-4b99-88e5-2cf7f45965bd" # Managed-CORS-With-Preflight

    viewer_protocol_policy = "redirect-to-https"

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
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

  lifecycle {
    ignore_changes = [
      default_cache_behavior,
      ordered_cache_behavior,
      viewer_certificate
    ]
  }

  tags = {
    Name = "CloudFront for ${each.key}"
    ENV  = var.environment
  }
}

resource "aws_cloudfront_distribution" "cdn" {
  for_each = var.cloudfront_distribution_path_pattern

  comment         = each.value.comment
  enabled         = true
  is_ipv6_enabled = true

  dynamic "origin" {
    for_each = var.cloudfront_origins
    iterator = i

    content {
      domain_name              = "${i.value.bucket_name}.s3.ap-northeast-2.amazonaws.com"
      origin_id                = "S3-${i.value.bucket_name}"
      origin_access_control_id = aws_cloudfront_origin_access_control.oac[i.value.oac_id].id
    }
  }

  default_cache_behavior {
    target_origin_id = "S3-${each.value.bucket_name}"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
    origin_request_policy_id   = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # Managed-CORS-S3Origin
    response_headers_policy_id = "5cc3b908-e619-4b99-88e5-2cf7f45965bd" # Managed-CORS-With-Preflight

    viewer_protocol_policy = "redirect-to-https"

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.cloudfront_origins
    iterator = i

    content {
      target_origin_id = "S3-${i.value.bucket_name}"
      path_pattern     = i.value.path_pattern

      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]

      cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
      origin_request_policy_id   = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # Managed-CORS-S3Origin
      response_headers_policy_id = "5cc3b908-e619-4b99-88e5-2cf7f45965bd" # Managed-CORS-With-Preflight

      viewer_protocol_policy = "redirect-to-https"

      min_ttl     = 0
      default_ttl = 3600
      max_ttl     = 86400
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

  lifecycle {
    ignore_changes = [
      default_cache_behavior,
      ordered_cache_behavior,
      viewer_certificate
    ]
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
            "AWS:SourceArn": "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${can(aws_cloudfront_distribution.cdn[each.value.distribution].id) ? aws_cloudfront_distribution.cdn[each.value.distribution].id : aws_cloudfront_distribution.cdn_web[each.value.distribution].id}"
          }
        }
      }
    ]
  }
  POLICY
}
