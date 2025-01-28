resource "aws_db_subnet_group" "db_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = var.db_subnet_ids

  tags = {
    Name        = var.db_subnet_group_name
    Environment = var.environment
  }
}

resource "aws_db_instance" "rds" {
  identifier                      = lower("${var.environment}-${var.rds_config.db_name}-${var.rds_config.db_engine}")
  engine                          = var.rds_config.db_engine
  engine_version                  = var.rds_config.db_engine_version
  instance_class                  = var.rds_config.db_instance_class
  allocated_storage               = var.rds_config.allocated_storage
  vpc_security_group_ids          = var.rds_config.db_security_group_ids
  db_subnet_group_name            = aws_db_subnet_group.db_subnet_group.name
  multi_az                        = var.rds_config.multi_az
  publicly_accessible             = var.rds_config.publicly_accessible
  storage_type                    = var.rds_config.storage_type
  db_name                         = var.rds_config.db_name
  username                        = var.rds_config.db_username
  password                        = var.rds_config.db_password
  skip_final_snapshot             = var.rds_config.skip_final_snapshot
  enabled_cloudwatch_logs_exports = var.rds_config.logs_type
  # parameter_group_name   = var.rds_config.db_parameter_group_name
  storage_encrypted = true

  backup_retention_period = var.rds_config.snapshot_period
  backup_window           = var.rds_config.snapshot_window

  tags = {
    Name        = upper("${var.environment}-${var.rds_config.db_name}")
    Environment = var.environment
  }
}

# resource "aws_db_instance" "rds_read_replica" {
#   identifier                 = lower("${var.environment}-${var.rds_read_replica_config.db_name}-${var.rds_config.db_engine}")
#   replicate_source_db        = aws_db_instance.rds.identifier
#   replica_mode               = "open-read-only"
#   auto_minor_version_upgrade = true
#   instance_class             = var.rds_read_replica_config.db_instance_class
#   multi_az                   = false
#   skip_final_snapshot        = var.rds_read_replica_config.skip_final_snapshot
#   storage_encrypted          = true
#
#   backup_retention_period = var.rds_read_replica_config.snapshot_period
#
#   tags = {
#     Name        = upper("${var.environment}-${var.rds_config.db_name}-Read-Replica")
#     Environment = var.environment
#   }
# }
