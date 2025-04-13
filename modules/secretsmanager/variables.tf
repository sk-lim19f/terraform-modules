variable "secretsmanager_secret" {
  type = map(object({
    name        = string
    description = string
  }))
}

variable "secretsmanager_secret_version" {
  type = map(object({
    secretsmanager_secret_key = string
    secret_string             = string
  }))
}
