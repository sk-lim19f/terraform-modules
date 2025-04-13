variable "apigw_rest_api" {
  type = map(object({
    name        = string
    description = string
  }))
}

variable "apigw_authorizer" {
  type = map(object({
    name               = string
    apigw_rest_api_key = string
    provider_arns      = list(string)
  }))
}

variable "apigw_prefix" {
  type = map(object({
    apigw_rest_api_key = string
    prefix             = string
  }))
}

variable "apigw_resource" {
  type = map(object({
    apigw_rest_api_key = string
    prefix_key         = optional(string)
    path_part          = string
  }))
}

variable "apigw_method" {
  type = map(object({
    apigw_rest_api_key = string
    apigw_resource_key = string
    http_method        = string
    authorization_key  = string
    request_parameters = optional(map(string))
  }))
}

variable "apigw_method_response" {
  type = map(object({
    apigw_rest_api_key  = string
    apigw_resource_key  = string
    apigw_method_key    = string
    status_code         = string
    response_parameters = optional(map(string))
  }))
}

variable "apigw_integration" {
  type = map(object({

    apigw_rest_api_key      = string
    apigw_resource_key      = string
    apigw_method_key        = string
    integration_http_method = optional(string)
    type                    = string
    uri                     = optional(string)
    request_templates       = optional(map(string))
  }))
}

variable "apigw_integration_response" {
  type = map(object({
    apigw_rest_api_key  = string
    apigw_resource_key  = string
    apigw_method_key    = string
    status_code         = string
    response_parameters = optional(map(string))
  }))
}

variable "apigw_deployment" {
  type = map(object({
    apigw_rest_api_key = string
  }))
}

variable "apigw_stage" {
  type = map(object({
    deployment_key     = string
    apigw_rest_api_key = string
    stage_name         = string
  }))
}
