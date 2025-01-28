variable "environment" {
  type        = string
}

variable "redis_subnet_group" {
  type = map(object({
    name        = string
    subnet_ids  = list(string)
  }))
}

variable "redis" {
  type = map(object({
    replication_group_id       = string
    node_type                  = string
    num_cache_clusters         = optional(number)
    num_node_groups            = optional(number)
    cluster_mode               = string
    engine_version             = string
    parameter_group_name       = optional(string)
    port                       = optional(number)
    subnet_group_key           = string
    security_group_ids         = list(string)
    automatic_failover_enabled = bool
    apply_immediately          = bool
  }))
}
