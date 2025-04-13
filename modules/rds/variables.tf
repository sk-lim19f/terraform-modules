variable "environment" {
  type = string
}

variable "db_subnet_group_name" {
  type = string
}

variable "db_subnet_ids" {
  type = list(string)
}

variable "rds_config" {
  type = map(object({
    db_name                             = string
    db_engine                           = string
    db_engine_version                   = string
    db_instance_class                   = string
    allocated_storage                   = number
    db_security_group_ids               = list(string)
    availability_zone                   = optional(string)
    multi_az                            = bool
    publicly_accessible                 = bool
    storage_type                        = string
    db_username                         = string
    db_password                         = string
    skip_final_snapshot                 = bool
    logs_type                           = list(string)
    db_parameter_group_key              = optional(string)
    iam_database_authentication_enabled = optional(bool)
    performance_insights_enabled        = optional(bool)
    monitoring_interval                 = optional(number)

    snapshot_period = number
    snapshot_window = string
  }))
}

variable "rds_read_replica_config" {
  type = map(object({
    source_db_name               = string
    source_db_engine             = string
    source_db_key                = string
    db_instance_class            = string
    skip_final_snapshot          = bool
    availability_zone            = optional(string)
    logs_type                    = list(string)
    performance_insights_enabled = optional(bool)
    monitoring_interval          = optional(number)

    snapshot_period = number
  }))
}

variable "rds_parameter_group" {
  type = map(object({
    name   = string
    family = string

    parameter = map(object({
      name  = string
      value = string
    }))
  }))
}
