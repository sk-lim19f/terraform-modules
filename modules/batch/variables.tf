variable "batch_compute" {
  type = map(object({
    compute_name = string
    service_role = string
    type         = string

    compute_resources = object({
      max_vcpus          = number
      security_group_ids = list(string)
      subnets            = list(string)
      instance_type      = string
    })
  }))
}

variable "batch_job_queue" {
  type = map(object({
    job_queue_name = string
    priority       = number
    state          = string

    compute_environment_order = object({
      batch_compute_key = string
      order             = number
    })
  }))
}

variable "batch_job_definition" {
  type = map(object({
    job_definition_name = string
    type                = string

    container_properties = object({
      ecr_uri      = string
      command      = list(string)
      job_role_arn = string

      vcpu   = string
      memory = string
    })
  }))
}
