variable "environment" {
  type        = string
}

variable "ecs_clusters" {
  type = map(object({
    product = string
  }))
}

variable "ecs_task_definitions" {
  type = map(object({
    product                = string
    service                = string
    ecs_execution_role_arn = string
    ecs_task_role_arn      = string

    container_definitions = list(object({
      name              = string
      image             = string
      cpu               = number
      memory            = number
      memoryReservation = number
      is_sidecar        = optional(bool, false)
      portMappings = list(object({
        container_port = number
        host_port      = number
        protocol       = optional(string, "tcp")
      }))

      environment = list(object({
        name  = string
        value = string
      }))
      logConfiguration = object({
        logDriver = string
        options   = map(string)
      })
      user       = optional(string)
      command    = optional(list(string), null)
      entryPoint = optional(list(string), null)
      mountPoints = optional(list(object({
        sourceVolume  = string
        containerPath = string
        readOnly      = bool
      })))
      dependsOn = optional(list(object({
        containerName = string
        condition     = string
      })))
    }))
    volumes = optional(list(object({
      name     = string
      hostPath = optional(string)
      efs_volume_configuration = optional(object({
        file_system_id  = optional(string)
        root_directory  = optional(string)
        access_point_id = optional(string)
      }))
    })))
  }))
}

variable "ecs_task_definitions_fargate" {
  type = map(object({
    product                = string
    service                = string
    ecs_execution_role_arn = string
    ecs_task_role_arn      = string
    cpu                    = number
    memory                 = number

    container_definitions = list(object({
      name              = string
      image             = string
      cpu               = number
      memory            = number
      memoryReservation = optional(number, null)
      is_sidecar        = optional(bool, false)
      portMappings = list(object({
        container_port = number
        host_port      = number
        protocol       = optional(string, "tcp")
      }))

      environment = list(object({
        name  = string
        value = string
      }))
      logConfiguration = object({
        logDriver = string
        options   = map(string)
      })
      user       = optional(string)
      command    = optional(list(string), null)
      entryPoint = optional(list(string), null)
      mountPoints = optional(list(object({
        sourceVolume  = string
        containerPath = string
        readOnly      = bool
      })))
      dependsOn = optional(list(object({
        containerName = string
        condition     = string
      })))
    }))
    volumes = optional(list(object({
      name     = string
      hostPath = optional(string)
      efs_volume_configuration = optional(object({
        file_system_id  = optional(string)
        root_directory  = optional(string)
        access_point_id = optional(string)
      }))
    })))
  }))
}


variable "ecs_services" {
  type = map(object({
    product                = string
    service                = string
    cluster_name           = string
    task_definition_family = string
    desired_count          = number
    capacity_provider_name = string

    capacity_provider_strategy = optional(object({
      weight = number
      base   = number
    }))

    network_configuration = object({
      private_subnet_ids      = list(string)
      service_security_groups = list(string)
    })

    load_balancers = optional(list(object({
      target_group_arn = string
      container_name   = string
      container_port   = number
    })))
  }))
}

variable "ecs_launch_template" {
  type = map(object({
    product               = string
    ami_name              = string
    instance_type         = string
    key_pair              = string
    ec2_security_groups   = list(string)
    instance_profile_name = string
    user_data_sh          = string
    cluster_name          = string
  }))
}

variable "asg_configs" {
  type = map(object({
    product            = string
    desired_capacity   = number
    max_size           = number
    min_size           = number
    launch_template    = string
    private_subnet_ids = list(string)
  }))
}

variable "capacity_provider_configs" {
  type = map(object({
    product                   = string
    status                    = string
    target_capacity           = number
    minimum_scaling_step_size = number
    maximum_scaling_step_size = number
    instance_warmup_period    = number
  }))
}

variable "ecs_cluster_capacity_providers" {
  type = map(object({
    cluster_name       = string
    capacity_providers = list(string)
    default_strategy = object({
      capacity_provider = string
      weight            = number
      base              = number
    })
  }))
}

variable "ops_apm_alb_dns" {
  type        = string
}

variable "ops_efs_id" {
  type        = string
}
