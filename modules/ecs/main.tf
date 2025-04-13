resource "aws_ecs_cluster" "ecs_cluster" {
  for_each = var.ecs_clusters

  name = "${var.environment}-${each.value.product}-Cluster"
}

resource "aws_ecs_task_definition" "ecs_task_definitions" {
  for_each = var.ecs_task_definitions

  family                   = "${var.environment}-${each.value.product}-${each.value.service}-Task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = each.value.ecs_execution_role_arn
  task_role_arn            = each.value.ecs_task_role_arn

  dynamic "volume" {
    for_each = each.value.volumes != null ? each.value.volumes : []

    content {
      name      = volume.value.name
      host_path = volume.value.hostPath != null ? volume.value.hostPath : null

      dynamic "efs_volume_configuration" {
        for_each = volume.value.efs_volume_configuration != null ? [volume.value.efs_volume_configuration] : []

        content {
          file_system_id = efs_volume_configuration.value.file_system_id

          authorization_config {
            access_point_id = efs_volume_configuration.value.access_point_id
          }

          transit_encryption = "ENABLED"
        }
      }
    }
  }

  container_definitions = jsonencode([
    for container in each.value.container_definitions : {
      name              = container.name
      image             = container.image
      cpu               = container.cpu
      memory            = container.memory
      memoryReservation = container.memoryReservation
      essential         = container.is_sidecar != true
      portMappings = [
        for port in container.portMappings : {
          containerPort = port.container_port
          hostPort      = port.host_port
          protocol      = port.protocol != null ? port.protocol : "tcp"
        }
      ]
      environment      = container.environment
      logConfiguration = container.logConfiguration
      user             = container.user
      command          = container.command
      entryPoint       = container.entryPoint
      mountPoints = [
        for mount in(container.mountPoints != null ? container.mountPoints : []) : {
          sourceVolume  = mount.sourceVolume
          containerPath = mount.containerPath
          readOnly      = mount.readOnly
        }
      ]
      dependsOn = [
        for dep in(container.dependsOn != null ? container.dependsOn : []) : {
          containerName = dep.containerName
          condition     = dep.condition
        }
      ]
    }
  ])

  # Task Definitions 에 변동이 없을 경우 사용
  # lifecycle {
  #   ignore_changes = [
  #     container_definitions,
  #   ]
  # }
}

resource "aws_ecs_task_definition" "ecs_task_definitions_fargate" {
  for_each = var.ecs_task_definitions_fargate

  family                   = "${var.environment}-${each.value.product}-${each.value.service}-Task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = each.value.ecs_execution_role_arn
  task_role_arn            = each.value.ecs_task_role_arn

  cpu    = each.value.cpu
  memory = each.value.memory

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  dynamic "volume" {
    for_each = each.value.volumes != null ? each.value.volumes : []

    content {
      name      = volume.value.name
      host_path = volume.value.hostPath != null ? volume.value.hostPath : null

      dynamic "efs_volume_configuration" {
        for_each = volume.value.efs_volume_configuration != null ? [volume.value.efs_volume_configuration] : []

        content {
          file_system_id = efs_volume_configuration.value.file_system_id

          authorization_config {
            access_point_id = efs_volume_configuration.value.access_point_id
          }

          transit_encryption = "ENABLED"
        }
      }
    }
  }

  container_definitions = jsonencode([
    for container in each.value.container_definitions : {
      name              = container.name
      image             = container.image
      cpu               = container.cpu
      memory            = container.memory
      memoryReservation = container.memoryReservation
      essential         = container.is_sidecar != true
      portMappings = [
        for port in container.portMappings : {
          containerPort = port.container_port
          hostPort      = port.host_port
          protocol      = port.protocol != null ? port.protocol : "tcp"
        }
      ]
      environment      = container.environment
      logConfiguration = container.logConfiguration
      user             = container.user
      command          = container.command
      entryPoint       = container.entryPoint
      mountPoints = [
        for mount in(container.mountPoints != null ? container.mountPoints : []) : {
          sourceVolume  = mount.sourceVolume
          containerPath = mount.containerPath
          readOnly      = mount.readOnly
        }
      ]
      dependsOn = [
        for dep in(container.dependsOn != null ? container.dependsOn : []) : {
          containerName = dep.containerName
          condition     = dep.condition
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "ecs_service" {
  for_each = var.ecs_services

  name                               = "${var.environment}-${each.value.product}-${each.value.service}-Service"
  cluster                            = aws_ecs_cluster.ecs_cluster[each.value.cluster_name].id
  task_definition                    = aws_ecs_task_definition.ecs_task_definitions[each.value.task_definition_family].arn
  desired_count                      = each.value.desired_count
  deployment_minimum_healthy_percent = try(each.value.minimum_healthy_percent, null)

  deployment_circuit_breaker {
    enable   = try(each.value.deployment_circuit_breaker.enable, false)
    rollback = try(each.value.deployment_circuit_breaker.rollback, false)
  }

  dynamic "capacity_provider_strategy" {
    for_each = each.value.capacity_provider_strategy != null ? [each.value.capacity_provider_strategy] : []

    content {
      capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider[each.value.capacity_provider_name].name
      weight            = each.value.capacity_provider_strategy.weight
      base              = each.value.capacity_provider_strategy.base
    }
  }

  network_configuration {
    subnets          = each.value.network_configuration.private_subnet_ids
    security_groups  = each.value.network_configuration.service_security_groups
    assign_public_ip = false
  }

  dynamic "load_balancer" {
    for_each = each.value.load_balancers

    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  dynamic "service_registries" {
    for_each = each.value.service_registries != null ? [each.value.service_registries] : []

    content {
      registry_arn = service_registries.value.registry_arn
    }
  }

  depends_on = [
    aws_ecs_capacity_provider.ecs_capacity_provider
  ]

  lifecycle {
    ignore_changes = [
      task_definition,
    ]
  }
}

resource "aws_launch_template" "ecs_launch_template" {
  for_each = var.ecs_launch_template

  name                   = "${var.environment}-${each.value.name}-Launch-Template"
  image_id               = each.value.ami_name
  instance_type          = each.value.instance_type
  key_name               = each.value.key_pair
  update_default_version = true
  vpc_security_group_ids = try(each.value.vpc_security_group_ids, null)

  dynamic "network_interfaces" {
    for_each = each.value.network_interfaces != null ? [each.value.network_interfaces] : []

    content {
      subnet_id       = network_interfaces.value.subnet_id
      security_groups = try(each.value.ec2_security_groups, null)
    }
  }

  iam_instance_profile {
    name = each.value.instance_profile_name
  }

  credit_specification {
    cpu_credits = "standard"
  }

  user_data = base64encode(templatefile("${path.root}/scripts/user_data/${each.value.user_data_sh}", {
    cluster_name    = each.value.cluster_name
    ops_apm_alb_dns = var.ops_apm_alb_dns
    ops_efs_id      = var.ops_efs_id
  }))

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      encrypted             = true
      volume_type           = "gp3"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.environment}-${each.value.product}-EC2"
    }
  }
}

resource "aws_autoscaling_group" "ecs_instance" {
  for_each = var.asg_configs

  name                = "${var.environment}-${each.value.product}-ASG"
  desired_capacity    = each.value.desired_capacity
  max_size            = each.value.max_size
  min_size            = each.value.min_size
  vpc_zone_identifier = each.value.private_subnet_ids

  launch_template {
    id      = aws_launch_template.ecs_launch_template[each.value.launch_template].id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [
      desired_capacity,
      tag
    ]
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-${each.value.product}-EC2"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Product"
    value               = each.value.product
    propagate_at_launch = true
  }

  depends_on = [aws_launch_template.ecs_launch_template]
}

resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  for_each = var.capacity_provider_configs

  name = "${var.environment}-${each.value.product}-Capacity-Provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_instance[each.key].arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      status                    = each.value.status
      target_capacity           = each.value.target_capacity
      minimum_scaling_step_size = each.value.minimum_scaling_step_size
      maximum_scaling_step_size = each.value.maximum_scaling_step_size
      instance_warmup_period    = each.value.instance_warmup_period
    }
  }

  depends_on = [
    aws_ecs_cluster.ecs_cluster
  ]
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_provider" {
  for_each = var.ecs_cluster_capacity_providers

  cluster_name = aws_ecs_cluster.ecs_cluster[each.value.cluster_name].name
  capacity_providers = [
    for provider_name in each.value.capacity_providers : aws_ecs_capacity_provider.ecs_capacity_provider[provider_name].name
  ]

  dynamic "default_capacity_provider_strategy" {
    for_each = each.value.default_strategy
    content {
      capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider[default_capacity_provider_strategy.value.capacity_provider].name
      weight            = default_capacity_provider_strategy.value.weight
      base              = default_capacity_provider_strategy.value.base
    }
  }

  depends_on = [
    aws_autoscaling_group.ecs_instance
  ]
}
