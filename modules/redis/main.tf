resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  for_each = var.redis_subnet_group

  name        = each.value.name
  description = each.value.name
  subnet_ids  = each.value.subnet_ids

  tags = {
    Name        = each.value.name
    Environment = var.environment
  }
}


resource "aws_elasticache_replication_group" "redis" {
  for_each = var.redis

  replication_group_id        = each.value.replication_group_id
  description                 = each.value.replication_group_id
  node_type                   = each.value.node_type
  num_cache_clusters          = each.value.num_cache_clusters
  num_node_groups             = each.value.num_node_groups
  cluster_mode                = each.value.cluster_mode
  replicas_per_node_group     = each.value.replicas_per_node_group
  multi_az_enabled            = try(each.value.multi_az_enabled, false)
  engine                      = "redis"
  engine_version              = each.value.engine_version
  parameter_group_name        = try(each.value.parameter_group_name, null)
  port                        = try(each.value.port, null)
  subnet_group_name           = aws_elasticache_subnet_group.redis_subnet_group[each.value.subnet_group_key].name
  preferred_cache_cluster_azs = each.value.preferred_cache_cluster_azs
  security_group_ids          = each.value.security_group_ids
  automatic_failover_enabled  = each.value.automatic_failover_enabled # dev: false
  at_rest_encryption_enabled  = true
  transit_encryption_enabled  = true
  apply_immediately           = each.value.apply_immediately
  maintenance_window          = "sun:18:00-sun:19:00" # UST 기준 / KST 03 ~ 04
  snapshot_window             = "19:00-20:00"         # UST 기준 / KST 04 ~ 05
  snapshot_retention_limit    = 1

  tags = {
    Name        = each.value.replication_group_id
    Environment = var.environment
  }
}
