variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Name of the project"
  default     = "serverless-hello"
}

variable "environment_name" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "api_gateway_stage_name" {
  type        = string
  description = "API Gateway stage name"
  default     = "dev"
}

variable "owner" {
  type        = string
  description = "Resource owner tag"
  default     = "platform-team"
}

variable "api_key_value" {
  type        = string
  description = "Secret API key value for API Gateway"
  sensitive   = true
}
