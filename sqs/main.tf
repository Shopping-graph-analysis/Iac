# ============================================================================
# S3-SQS-Lambda Integration for Data Ingestion
# ============================================================================
# This configuration creates an event-driven architecture where:
# 1. S3 bucket receives uploaded files
# 2. S3 sends event notifications to SQS
# 3. SQS triggers Lambda function to process the files
# ============================================================================

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# ============================================================================
# S3 Bucket for Data Ingestion
# ============================================================================

module "data_ingestion_bucket" {
  source = "../modules/s3"

  bucket_name       = var.s3_bucket_name
  enable_versioning = true

  # Enable S3 event notifications to SQS
  enable_sqs_notification    = true
  sqs_queue_arn              = module.event_queue.queue_arn
  notification_events        = ["s3:ObjectCreated:*"]
  notification_filter_prefix = "" # Process all objects
  notification_filter_suffix = "" # No suffix filter

  tags = local.common_tags
}

# ============================================================================
# SQS Queue for S3 Event Notifications
# ============================================================================

module "event_queue" {
  source = "../modules/sqs"

  queue_name                = var.sqs_queue_name
  delay_seconds             = 0
  max_message_size          = 262144 # 256 KB
  message_retention_seconds = 345600 # 4 days
  receive_wait_time_seconds = 10     # Long polling

  # Enable S3 to send notifications
  enable_s3_notification = true
  s3_bucket_arn          = module.data_ingestion_bucket.bucket_arn

  tags = local.common_tags
}

# ============================================================================
# Lambda Function for Processing S3 Events
# ============================================================================

# Package Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

module "event_processor_lambda" {
  source = "../modules/lambda"

  function_name = var.lambda_function_name
  runtime       = var.lambda_runtime
  handler       = "lambda_function.lambda_handler"
  filename      = data.archive_file.lambda_zip.output_path
  timeout       = 60
  memory_size   = 256
  region        = var.aws_region

  # Enable SQS trigger
  enable_sqs_trigger = true
  sqs_queue_arn      = module.event_queue.queue_arn
  sqs_batch_size     = 10

  # Enable S3 read access
  enable_s3_access = true
  s3_bucket_arn    = module.data_ingestion_bucket.bucket_arn

  env_variables = {
    ENVIRONMENT = var.environment
    BUCKET_NAME = module.data_ingestion_bucket.bucket_name
  }

  tags = local.common_tags
}

# ============================================================================
# Outputs
# ============================================================================

output "s3_bucket_name" {
  description = "Name of the S3 bucket for data ingestion"
  value       = module.data_ingestion_bucket.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.data_ingestion_bucket.bucket_arn
}

output "sqs_queue_url" {
  description = "URL of the SQS queue"
  value       = module.event_queue.queue_url
}

output "sqs_queue_arn" {
  description = "ARN of the SQS queue"
  value       = module.event_queue.queue_arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.event_processor_lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.event_processor_lambda.function_arn
}
