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
  type = object({
    db_name               = string
    db_engine             = string
    db_engine_version     = string
    db_instance_class     = string
    allocated_storage     = number
    db_security_group_ids = list(string)
    multi_az              = bool
    publicly_accessible   = bool
    storage_type          = string
    db_username           = string
    db_password           = string
    skip_final_snapshot   = bool
    logs_type             = list(string)
    # db_parameter_group_name = string

    snapshot_period = number
    snapshot_window = string
  })
}

# variable "rds_read_replica_config" {
#   type = object({
#     db_name               = string
#     db_instance_class     = string
#     skip_final_snapshot   = bool
#
#     snapshot_period = number
#   })
# }
