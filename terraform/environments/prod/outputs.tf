output "hello_url" {
  description = "Invocation URL for the production /hello endpoint"
  value       = module.api.hello_url
}

output "function_name" {
  description = "Name of the deployed Lambda function"
  value       = module.lambda.function_name
}

output "published_version" {
  description = "Latest published version of the Lambda function"
  value       = module.lambda.version
}

output "active_color" {
  description = "The active color alias receiving live traffic"
  value       = var.active_color
}

output "deployment_color" {
  description = "The deployment version label in effect"
  value       = var.deployment_color
}
