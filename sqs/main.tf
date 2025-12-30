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
