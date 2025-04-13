variable "ecr_repository" {
  type = map(object({
    repository_name = string
    mutability      = string
  }))
}

variable "ecr_lifecycle_policy" {
  type = map(object({
    ecr_key = string
    policy  = string
  }))
}
