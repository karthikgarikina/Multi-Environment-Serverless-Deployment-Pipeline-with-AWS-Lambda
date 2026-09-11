output "hello_url" {
  description = "Invocation URL for the /hello endpoint"
  value       = module.api.hello_url
}

output "function_name" {
  description = "Name of the deployed Lambda function"
  value       = module.lambda.function_name
}

output "api_gateway_stage" {
  description = "API Gateway stage name"
  value       = module.api.stage_name
}
