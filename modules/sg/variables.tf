variable "vpc_id" {
  type        = string
}

variable "sg_configs" {
  type = map(object({
    product  = optional(string)
    service  = optional(string)
    resource = optional(string)
  }))
}

variable "sg_rules" {
  type = map(object({
    sg_name        = string
    type           = string
    from_port      = number
    to_port        = number
    protocol       = string
    cidr_blocks    = optional(list(string))
    source_sg_name = optional(string)
    description    = optional(string)
  }))
}

variable "environment" {
  type        = string
}
