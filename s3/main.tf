module "s3" {
  source      = "../modules/s3"
  bucket_name = "s3_ticket_storage"
  tags = {
    Name = "s3_ticket_storage"
  }
}
