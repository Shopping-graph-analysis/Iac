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
    Environment = "dev"
    Project     = "ticket-ingestion"
    ManagedBy   = "Terraform"
  }
}

data "aws_s3_bucket" "ticket_ingestion_bucket" {
  bucket = "s3-ticket-storage"
}

# ============================================================================
# SQS Queue for S3 Event Notifications
# ============================================================================

module "ticket_ingestion_queue" {
  source = "../modules/sqs"

  queue_name                = "ticket-ingestion-queue"
  delay_seconds             = 0
  max_message_size          = 262144 # 256 KB
  message_retention_seconds = 345600 # 4 days
  receive_wait_time_seconds = 10     # Long polling

  enable_s3_notification = true
  s3_bucket_arn          = data.aws_s3_bucket.ticket_ingestion_bucket.arn

  tags = local.common_tags
}
