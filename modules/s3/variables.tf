variable "bucket_name" {
  type = string
}

variable "enable_versioning" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "enable_sqs_notification" {
  description = "Enable S3 event notifications to SQS"
  type        = bool
  default     = false
}

variable "sqs_queue_arn" {
  description = "ARN of the SQS queue to send notifications to"
  type        = string
  default     = ""
}

variable "notification_events" {
  description = "List of S3 events to trigger notifications"
  type        = list(string)
  default     = ["s3:ObjectCreated:*"]
}

variable "notification_filter_prefix" {
  description = "Object key prefix to filter notifications"
  type        = string
  default     = ""
}

variable "notification_filter_suffix" {
  description = "Object key suffix to filter notifications"
  type        = string
  default     = ""
}
