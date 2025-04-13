resource "aws_service_discovery_private_dns_namespace" "cloud_map_namespace" {
  for_each = var.cloud_map_namespace

  name = each.value.name
  vpc  = each.value.vpc_id
}

resource "aws_service_discovery_service" "cloud_map_service" {
  for_each = var.cloud_map_service

  name = each.value.name

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.cloud_map_namespace[each.value.dns_config.namespace_key].id

    dns_records {
      ttl  = 300
      type = "A"
    }

    routing_policy = each.value.dns_config.routing_policy
  }
}