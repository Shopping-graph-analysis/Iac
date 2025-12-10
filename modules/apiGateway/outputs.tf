output "api_id" {
  description = "The ID of the REST API"
  value       = aws_api_gateway_rest_api.this.id
}

output "stage_invoke_url" {
  description = "The URL to invoke the API Stage"
  value       = aws_api_gateway_stage.this.invoke_url
}
