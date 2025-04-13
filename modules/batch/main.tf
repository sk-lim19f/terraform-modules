resource "aws_batch_compute_environment" "batch_compute" {
  for_each = var.batch_compute

  compute_environment_name = each.value.compute_name
  service_role             = each.value.service_role
  type                     = each.value.type

  compute_resources {
    max_vcpus          = each.value.compute_resources.max_vcpus
    security_group_ids = each.value.compute_resources.security_group_ids
    subnets            = each.value.compute_resources.subnets
    type               = each.value.compute_resources.instance_type
  }
}

resource "aws_batch_job_queue" "batch_job_queue" {
  for_each = var.batch_job_queue

  name     = each.value.job_queue_name
  priority = each.value.priority
  state    = each.value.state

  compute_environment_order {
    compute_environment = aws_batch_compute_environment.batch_compute[each.value.compute_environment_order.batch_compute_key].arn
    order               = each.value.compute_environment_order.order
  }

  depends_on = [aws_batch_compute_environment.batch_compute]
}

resource "aws_batch_job_definition" "batch_job_definition" {
  for_each = var.batch_job_definition

  name = each.value.job_definition_name
  type = each.value.type

  platform_capabilities = ["FARGATE"]

  container_properties = jsonencode({
    image      = each.value.container_properties.ecr_uri
    command    = each.value.container_properties.command
    jobRoleArn = each.value.container_properties.job_role_arn

    resourceRequirements = [
      {
        type  = "VCPU"
        value = each.value.container_properties.vcpu
      },
      {
        type  = "MEMORY"
        value = each.value.container_properties.memory
      }
    ]

    fargatePlatformConfiguration = {
      platformVersion = "LATEST"
    }

    executionRoleArn = each.value.container_properties.job_role_arn
  })
}
