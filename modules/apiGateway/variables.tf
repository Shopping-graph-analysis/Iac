variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "api_description" {
  description = "Description of the API Gateway"
  type        = string
  default     = "API Gateway for Lambda integration"
}

variable "api_stage_name" {
  description = "Name of the stage"
  type        = string
  default     = "dev"
}

variable "endpoints" {
  description = "Map of endpoints to create"
  type = map(object({
    path_part            = string
    method               = string
    lambda_invoke_arn    = string
    lambda_function_name = string
  }))

  validation {
    condition = alltrue([
      for k, v in var.endpoints : contains(["GET", "POST", "PUT", "DELETE", "PATCH", "ANY"], v.method)
    ])
    error_message = "Method must be one of GET, POST, PUT, DELETE, PATCH, or ANY."
  }
}
