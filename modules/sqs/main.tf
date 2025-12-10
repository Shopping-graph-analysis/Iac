resource "aws_sqs_queue" "this" {
  name                      = var.queue_name
  delay_seconds             = var.delay_seconds
  max_message_size          = var.max_message_size
  message_retention_seconds = var.message_retention_seconds
  receive_wait_time_seconds = var.receive_wait_time_seconds
  tags                      = var.tags
}

# SQS Queue Policy to allow S3 to send messages
resource "aws_sqs_queue_policy" "this" {
  count     = var.enable_s3_notification ? 1 : 0
  queue_url = aws_sqs_queue.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "SQS:SendMessage"
        Resource = aws_sqs_queue.this.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = var.s3_bucket_arn
          }
        }
      }
    ]
  })
}
