variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "shopping-graph"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for data ingestion"
  type        = string
  default     = "shopping-graph-data-ingestion"
}

variable "sqs_queue_name" {
  description = "Name of the SQS queue"
  type        = string
  default     = "s3-event-notification-queue"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "s3-event-processor"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.11"
}
