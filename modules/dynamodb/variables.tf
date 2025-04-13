variable "dynamodb_table" {
  type = map(object({

    table_name   = string
    billing_mode = string

    hash_key  = string
    range_key = optional(string)

    attribute = list(object({
      name = string
      type = string
    }))

    global_secondary_index = optional(object({
      name            = string
      hash_key        = string
      projection_type = string
    }))
  }))
}
