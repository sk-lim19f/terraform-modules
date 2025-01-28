output "ecs_cluster_ids" {
  value       = [for cluster in aws_ecs_cluster.ecs_cluster : cluster.id]
}

output "task_definition_arns" {
  value       = [for task in aws_ecs_task_definition.ecs_task_definitions : task.arn]
}

output "ecs_service_arns" {
  value       = [for key, service in aws_ecs_service.ecs_service : lookup(service, "arn", null)]
}

output "asg_names" {
  value       = { for key, asg in aws_autoscaling_group.ecs_instance : key => asg.name }
}

output "ecs_services" {
  value       = { for key, service in aws_ecs_service.ecs_service : key => service.name }
}
