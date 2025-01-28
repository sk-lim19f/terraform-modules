resource "aws_opensearch_domain" "search_engine" {
  for_each = var.search_engine_domain

  domain_name    = each.value.domain_name
  engine_version = each.value.engine_version

  vpc_options {
    subnet_ids         = try(each.value.vpc_options.subnet_ids, null)
    security_group_ids = try(each.value.vpc_options.sg_ids, [])
  }

  advanced_security_options {
    anonymous_auth_enabled         = false
    enabled                        = true
    internal_user_database_enabled = true

    master_user_options {
      master_user_arn      = null
      master_user_name     = each.value.advanced_security_options.master_user_name
      master_user_password = each.value.advanced_security_options.master_user_password
    }
  }

  cluster_config {
    instance_type  = try(each.value.cluster_config.instance_type, "t3.small.search")
    instance_count = try(each.value.cluster_config.instance_count, 1)

    zone_awareness_enabled = try(each.value.cluster_config.multiple_az_enabled, false)

    dynamic "zone_awareness_config" {
      for_each = each.value.cluster_config.multiple_az_enabled ? [each.value.cluster_config.zone_awareness_config] : []

      content {
        availability_zone_count = zone_awareness_config.value.az_count
      }
    }

    dedicated_master_enabled = try(each.value.cluster_config.master_enabled, false)
    dedicated_master_type    = try(each.value.cluster_config.master_type, null)
    dedicated_master_count   = try(each.value.cluster_config.master_count, 0)

    warm_enabled = try(each.value.cluster_config.warm_enable, false)
    warm_type    = try(each.value.cluster_config.warm_type, null)
    warm_count   = try(each.value.cluster_config.warm_count, 0)
  }

  timeouts {
    create = try(each.value.timeouts.create, null)
    delete = try(each.value.timeouts.delete, null)
  }

  ebs_options {
    ebs_enabled = try(each.value.ebs_options.ebs_enabled, true)
    volume_size = try(each.value.ebs_options.ebs_volume_size, 30)
    volume_type = try(each.value.ebs_options.ebs_volume_type, "gp3")
  }

  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https                   = true
    custom_endpoint                 = try(each.value.domain_endpoint_options.custom_endpoint, null)
    custom_endpoint_certificate_arn = try(each.value.domain_endpoint_options.custom_endpoint_certificate_arn, null)
    tls_security_policy             = "Policy-Min-TLS-1-2-2019-07"
  }

  auto_tune_options {
    desired_state       = try(each.value.auto_tune_options.state, "ENABLED")
    rollback_on_disable = try(each.value.auto_tune_options.rollback_on_disable, "NO_ROLLBACK")
    use_off_peak_window = try(each.value.auto_tune_options.off_peak, false)

    maintenance_schedule {
      cron_expression_for_recurrence = try(each.value.auto_tune_options.maintenance_schedules.cron_expression_for_recurrence, null)
      start_at                       = "2025-01-14T18:00:00Z"

      duration {
        unit  = "HOURS"
        value = 2
      }
    }
  }

  snapshot_options {
    automated_snapshot_start_hour = try(each.value.snapshot_options.snapshot_hour, 19)
  }

  dynamic "log_publishing_options" {
    for_each = each.value.log_publishing_options

    content {
      enabled                  = log_publishing_options.value.enabled
      cloudwatch_log_group_arn = log_publishing_options.value.cloudwatch_log_group_arn
      log_type                 = log_publishing_options.value.log_type
    }
  }

  tags = {
    ENV = var.environment
  }
}

resource "aws_opensearch_package_association" "search_engine_package_association" {
  for_each = var.search_engine_package_association

  domain_name = aws_opensearch_domain.search_engine[each.value.domain_key].domain_name
  package_id  = each.value.package_id

  depends_on = [aws_opensearch_domain.search_engine]
}

resource "aws_opensearch_domain_policy" "search_engine_policy" {
  for_each = var.search_engine_policy

  domain_name     = aws_opensearch_domain.search_engine[each.value.domain_key].domain_name
  access_policies = each.value.access_policies
}
