provider "aws" {
  region = "eu-west-1"

  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  s3_use_path_style           = true

  # endpoints {
  #   lambda = "http://localhost:4566"
  # }
}
