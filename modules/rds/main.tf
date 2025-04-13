resource "aws_db_subnet_group" "db_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = var.db_subnet_ids

  tags = {
    Name        = var.db_subnet_group_name
    Environment = var.environment
  }
}

resource "aws_db_instance" "rds" {
  for_each = var.rds_config

  identifier                          = lower("${var.environment}-${each.value.db_name}-${each.value.db_engine}")
  engine                              = each.value.db_engine
  engine_version                      = each.value.db_engine_version
  instance_class                      = each.value.db_instance_class
  allocated_storage                   = each.value.allocated_storage
  vpc_security_group_ids              = each.value.db_security_group_ids
  db_subnet_group_name                = aws_db_subnet_group.db_subnet_group.name
  availability_zone                   = try(each.value.availability_zone, null)
  multi_az                            = each.value.multi_az
  publicly_accessible                 = each.value.publicly_accessible
  storage_type                        = each.value.storage_type
  db_name                             = each.value.db_name
  username                            = each.value.db_username
  password                            = each.value.db_password
  skip_final_snapshot                 = each.value.skip_final_snapshot
  final_snapshot_identifier           = lower("${var.environment}-${each.value.db_name}-${each.value.db_engine}-Snapshot")
  iam_database_authentication_enabled = try(each.value.iam_database_authentication_enabled, false)
  performance_insights_enabled        = try(each.value.performance_insights_enabled, false)
  monitoring_interval                 = try(each.value.monitoring_interval, null)
  enabled_cloudwatch_logs_exports     = each.value.logs_type
  parameter_group_name                = try(aws_db_parameter_group.rds_parameter_group[each.value.db_parameter_group_key].name, null)
  storage_encrypted                   = true

  backup_retention_period = each.value.snapshot_period
  backup_window           = each.value.snapshot_window

  tags = {
    Name        = upper("${var.environment}-${each.value.db_name}")
    Environment = var.environment
  }
}

resource "aws_db_instance" "rds_read_replica" {
  for_each = var.rds_read_replica_config

  identifier                      = lower("${var.environment}-${each.value.source_db_name}-${each.value.source_db_engine}-Read-Replica")
  replicate_source_db             = aws_db_instance.rds[each.value.source_db_key].identifier
  auto_minor_version_upgrade      = true
  instance_class                  = each.value.db_instance_class
  availability_zone               = try(each.value.availability_zone, null)
  enabled_cloudwatch_logs_exports = each.value.logs_type
  performance_insights_enabled    = each.value.performance_insights_enabled
  monitoring_interval             = each.value.monitoring_interval
  multi_az                        = false
  skip_final_snapshot             = each.value.skip_final_snapshot
  # final_snapshot_identifier  = "${var.environment}-${each.value.source_db_name}-${each.value.source_db_engine}-Snapshot"
  storage_encrypted = true

  backup_retention_period = each.value.snapshot_period

  tags = {
    Name        = upper("${var.environment}-${each.value.source_db_name}-Read-Replica")
    Environment = var.environment
  }
}

resource "aws_db_parameter_group" "rds_parameter_group" {
  for_each = var.rds_parameter_group

  name   = each.value.name
  family = each.value.family

  dynamic "parameter" {
    for_each = each.value.parameter

    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
}
