output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "invoke_arn" {
  description = "Invocation ARN of the Lambda function for API Gateway"
  value       = aws_lambda_function.this.invoke_arn
}

output "version" {
  description = "Latest published version of the Lambda function"
  value       = aws_lambda_function.this.version
}

output "role_arn" {
  description = "ARN of the IAM role assumed by Lambda"
  value       = aws_iam_role.this.arn
}
