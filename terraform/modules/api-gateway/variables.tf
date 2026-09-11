variable "name" {
  type        = string
  description = "Name for the API Gateway REST API and related resources"
}

variable "stage_name" {
  type        = string
  description = "The deployment stage name (e.g. dev, staging, prod)"
}

variable "lambda_invoke_arn" {
  type        = string
  description = "Target Lambda invocation ARN (or qualified alias ARN)"
}

variable "lambda_function_name" {
  type        = string
  description = "Target Lambda function name (or alias) for IAM permission grant"
}

variable "api_key_value" {
  type        = string
  description = "Value of the API key used to secure the endpoint"
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  description = "Resource tags applied to API Gateway and associated resources"
  default     = {}
}
