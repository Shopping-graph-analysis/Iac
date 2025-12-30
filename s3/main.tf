module "s3" {
  source      = "../modules/s3"
  bucket_name = "s3-ticket-storage"
  tags = {
    Name = "s3-ticket-storage"
  }
}
