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
  default     = "prod"
}

variable "api_gateway_stage_name" {
  type        = string
  description = "API Gateway stage name"
  default     = "prod"
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

variable "active_color" {
  type        = string
  description = "The active production Lambda alias that API Gateway directs traffic to (blue or green)"
  default     = "blue"

  validation {
    condition     = contains(["blue", "green"], var.active_color)
    error_message = "active_color must be blue or green."
  }
}

variable "deployment_color" {
  type        = string
  description = "The deployment version label passed into the Lambda environment (Blue or Green)"
  default     = "Blue"

  validation {
    condition     = contains(["Blue", "Green"], var.deployment_color)
    error_message = "deployment_color must be Blue or Green."
  }
}
