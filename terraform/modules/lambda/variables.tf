variable "function_name" {
  type        = string
  description = "The name of the Lambda function"
}

variable "environment_name" {
  type        = string
  description = "The deployment environment name (dev, staging, prod)"
}

variable "source_dir" {
  type        = string
  description = "Path to the directory containing the Lambda source code"
}

variable "version_label" {
  type        = string
  description = "Optional version label for blue/green deployment tracking"
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Resource tags applied to Lambda and associated resources"
  default     = {}
}
