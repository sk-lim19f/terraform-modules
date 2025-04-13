output "apigw_rest_api_exec_arn" {
  value       = { for k, apigw_rest_api in aws_api_gateway_rest_api.apigw_rest_api : k => apigw_rest_api.execution_arn }
}