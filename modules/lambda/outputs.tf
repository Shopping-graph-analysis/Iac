output "function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.lambda_function.arn
}

output "function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.lambda_function.function_name
}

output "function_invoke_arn" {
  description = "The invoke ARN of the Lambda function"
  value       = aws_lambda_function.lambda_function.invoke_arn
}

output "role_arn" {
  description = "The ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.arn
}

output "role_name" {
  description = "The name of the Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.name
}
