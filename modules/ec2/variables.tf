variable "environment" {
  type = string
}

variable "ec2_instance" {
  type = map(object({
    name = string

    ami_name      = string
    instance_type = string
    key_pair      = string

    ec2_security_groups = list(string)
    subnet_id           = string

    iam_instance_profile = optional(string)
  }))
}
