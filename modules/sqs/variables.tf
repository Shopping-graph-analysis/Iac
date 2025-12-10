variable "queue_name" {
  description = "Name of the SQS queue"
  type        = string
}

variable "delay_seconds" {
  description = "Delay in seconds"
  type        = number
  default     = 90
}

variable "max_message_size" {
  description = "Maximum message size in bytes"
  type        = number
  default     = 2048
}

variable "message_retention_seconds" {
  description = "Message retention period in seconds"
  type        = number
  default     = 86400
}

variable "receive_wait_time_seconds" {
  description = "Receive wait time in seconds"
  type        = number
  default     = 10
}

variable "tags" {
  description = "Tags for the SQS queue"
  type        = map(string)
  default     = {}
}

variable "enable_s3_notification" {
  description = "Enable S3 to send notifications to this queue"
  type        = bool
  default     = false
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket allowed to send messages"
  type        = string
  default     = ""
}
