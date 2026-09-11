output "hello_url" {
  description = "Public URL for the /hello endpoint"
  value       = "${aws_api_gateway_stage.this.invoke_url}/hello"
}

output "rest_api_id" {
  description = "ID of the REST API Gateway"
  value       = aws_api_gateway_rest_api.this.id
}

output "stage_name" {
  description = "Deployed API Gateway stage name"
  value       = aws_api_gateway_stage.this.stage_name
}

output "execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.this.execution_arn
}

output "api_key_id" {
  description = "ID of the created API Key"
  value       = aws_api_gateway_api_key.this.id
}
