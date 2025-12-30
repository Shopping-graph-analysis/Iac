resource "aws_s3_bucket" "s3_bucket" {
  bucket = "tfstate-aws-shopping-graph-analysis"
}

resource "aws_s3_bucket_versioning" "versioning" {
  depends_on = [aws_s3_bucket.s3_bucket]
  bucket     = aws_s3_bucket.s3_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
