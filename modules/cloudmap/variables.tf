variable "cloud_map_namespace" {
  type = map(object({
    name   = string
    vpc_id = string
  }))
}

variable "cloud_map_service" {
  type = map(object({
    name = string

    dns_config = object({
      namespace_key  = string
      routing_policy = string
    })
  }))
}
