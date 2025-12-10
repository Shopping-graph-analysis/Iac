resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.s3_bucket.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = var.enable_sqs_notification ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket.id

  queue {
    queue_arn     = var.sqs_queue_arn
    events        = var.notification_events
    filter_prefix = var.notification_filter_prefix
    filter_suffix = var.notification_filter_suffix
  }
}
