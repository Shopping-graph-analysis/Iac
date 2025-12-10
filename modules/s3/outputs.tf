output "bucket_id" {
  description = "The ID of the S3 bucket"
  value       = aws_s3_bucket.s3_bucket.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.s3_bucket.arn
}

output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.s3_bucket.bucket
}

output "bucket_domain_name" {
  description = "The bucket domain name"
  value       = aws_s3_bucket.s3_bucket.bucket_domain_name
}
