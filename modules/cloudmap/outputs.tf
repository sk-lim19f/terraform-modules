output "service_ids" {
  value = { for k, cloud_map_service in aws_service_discovery_service.cloud_map_service : k => cloud_map_service.arn }
}