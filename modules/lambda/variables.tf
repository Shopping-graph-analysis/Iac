variable "function_name" {
  type        = string
  description = "Name of the lambda function"
}

variable "runtime" {
  type        = string
  description = "Runtime for the lambda function"
  validation {
    condition     = contains(["python3.11", "python3.12", "java17", "java21", "java25"], var.runtime)
    error_message = "Runtime must be one of: python3.11, python3.12, java17, java21, java25"
  }
}

variable "env_variables" {
  type        = map(string)
  description = "Environment variables for the lambda function"
  default     = {}
}

variable "region" {
  type        = string
  description = "Region for the lambda function"
}

variable "env" {
  type        = map(string)
  description = "Environment for the lambda function"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags for the lambda function"
  default     = {}
}

variable "filename" {
  type        = string
  description = "Filename for the lambda function"
}

variable "handler" {
  type        = string
  description = "Handler for the lambda function"
}

variable "timeout" {
  type        = number
  description = "Timeout for the lambda function in seconds"
  default     = 60
}

variable "memory_size" {
  type        = number
  description = "Memory size for the lambda function in MB"
  default     = 256
}

variable "enable_sqs_trigger" {
  type        = bool
  description = "Enable SQS event source mapping"
  default     = false
}

variable "sqs_queue_arn" {
  type        = string
  description = "ARN of the SQS queue to trigger Lambda"
  default     = ""
}

variable "sqs_batch_size" {
  type        = number
  description = "Maximum number of messages to retrieve from SQS"
  default     = 10
}

variable "enable_s3_access" {
  type        = bool
  description = "Enable S3 read access for Lambda"
  default     = false
}

variable "s3_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket to grant access to"
  default     = ""
}
