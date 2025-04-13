variable "cognito_user_pool" {
  type = map(object({
    name = string
  }))
}

variable "cognito_user_pool_client" {
  type = map(object({
    name          = string
    user_pool_key = string

    explicit_auth_flows = list(string)

    generate_secret = bool

    allowed_oauth_flows                  = optional(list(string))
    allowed_oauth_scopes                 = optional(list(string))
    callback_urls                        = optional(list(string))
    logout_urls                          = optional(list(string))
    allowed_oauth_flows_user_pool_client = optional(bool)
  }))
}

variable "cognito_user_pool_domain" {
  type = map(object({
    domain        = string
    user_pool_key = string
  }))
}

variable "cognito_user_group" {
  type = map(object({
    name          = string
    user_pool_key = string
  }))
}
