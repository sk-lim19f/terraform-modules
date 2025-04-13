terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
  }
}
resource "aws_api_gateway_rest_api" "apigw_rest_api" {
  for_each = var.apigw_rest_api

  name        = each.value.name
  description = each.value.description

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_authorizer" "apigw_authorizer" {
  for_each = var.apigw_authorizer

  name            = each.value.name
  rest_api_id     = aws_api_gateway_rest_api.apigw_rest_api[each.value.apigw_rest_api_key].id
  identity_source = "method.request.header.Authorization"
  type            = "COGNITO_USER_POOLS"
  provider_arns   = each.value.provider_arns
}

resource "aws_api_gateway_resource" "apigw_prefix" {
  for_each = var.apigw_prefix

  rest_api_id = aws_api_gateway_rest_api.apigw_rest_api[each.value.apigw_rest_api_key].id
  parent_id   = aws_api_gateway_rest_api.apigw_rest_api[each.value.apigw_rest_api_key].root_resource_id
  path_part   = each.value.prefix
}


resource "aws_api_gateway_resource" "apigw_resource" {
  for_each = var.apigw_resource

  rest_api_id = aws_api_gateway_rest_api.apigw_rest_api[each.value.apigw_rest_api_key].id
  parent_id   = try(aws_api_gateway_resource.apigw_prefix[each.value.prefix_key].id, aws_api_gateway_rest_api.apigw_rest_api[each.value.apigw_rest_api_key].root_resource_id)
  path_part   = each.value.path_part
}

resource "aws_api_gateway_method" "apigw_method" {
  for_each = var.apigw_method

  rest_api_id   = aws_api_gateway_rest_api.apigw_rest_api[each.value.apigw_rest_api_key].id
  resource_id   = aws_api_gateway_resource.apigw_resource[each.value.apigw_resource_key].id
  http_method   = each.value.http_method
  authorization = each.value.authorization_key == "NONE" ? "NONE" : aws_api_gateway_authorizer.apigw_authorizer[each.value.authorization_key].type
  authorizer_id = each.value.authorization_key == "NONE" ? null : aws_api_gateway_authorizer.apigw_authorizer[each.value.authorization_key].id

  request_parameters = each.value.request_parameters
}

resource "aws_api_gateway_method_response" "apigw_method_response" {
  for_each = var.apigw_method_response

  rest_api_id         = aws_api_gateway_rest_api.apigw_rest_api[each.value.apigw_rest_api_key].id
  resource_id         = aws_api_gateway_resource.apigw_resource[each.value.apigw_resource_key].id
  http_method         = aws_api_gateway_method.apigw_method[each.value.apigw_method_key].http_method
  status_code         = each.value.status_code
  response_parameters = each.value.response_parameters

  depends_on = [aws_api_gateway_method.apigw_method]
}

resource "aws_api_gateway_integration" "apigw_integration" {
  for_each = var.apigw_integration

  rest_api_id             = aws_api_gateway_rest_api.apigw_rest_api[each.value.apigw_rest_api_key].id
  resource_id             = aws_api_gateway_resource.apigw_resource[each.value.apigw_resource_key].id
  http_method             = aws_api_gateway_method.apigw_method[each.value.apigw_method_key].http_method
  integration_http_method = each.value.integration_http_method
  type                    = each.value.type
  uri                     = each.value.uri
  request_templates       = each.value.request_templates
}

resource "aws_api_gateway_integration_response" "apigw_integration_response" {
  for_each = var.apigw_integration_response

  rest_api_id         = aws_api_gateway_rest_api.apigw_rest_api[each.value.apigw_rest_api_key].id
  resource_id         = aws_api_gateway_resource.apigw_resource[each.value.apigw_resource_key].id
  http_method         = aws_api_gateway_method.apigw_method[each.value.apigw_method_key].http_method
  status_code         = each.value.status_code
  response_parameters = each.value.response_parameters

  depends_on = [aws_api_gateway_integration.apigw_integration]
}

resource "aws_api_gateway_deployment" "apigw_deployment" {
  for_each = var.apigw_deployment

  rest_api_id = aws_api_gateway_rest_api.apigw_rest_api[each.value.apigw_rest_api_key].id

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.apigw_integration
  ]
}

resource "aws_api_gateway_stage" "apigw_stage" {
  for_each = var.apigw_stage

  deployment_id = aws_api_gateway_deployment.apigw_deployment[each.value.deployment_key].id
  rest_api_id   = aws_api_gateway_rest_api.apigw_rest_api[each.value.apigw_rest_api_key].id
  stage_name    = each.value.stage_name
}
