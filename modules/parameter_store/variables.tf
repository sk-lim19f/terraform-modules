variable "parameter" {
  type = map(object({
    name        = string
    description = optional(string)
    type        = string
    value       = string
    version     = number
  }))
}
