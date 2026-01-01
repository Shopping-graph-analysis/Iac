terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.13.0"
    }
  }
  backend "s3" {
    bucket       = "tfstate-aws-shopping-graph-analysis"
    key          = "lambda/lambda.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
  }
}

