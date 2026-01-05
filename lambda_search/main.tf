data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/main.py"
  output_path = "${path.module}/lambda_function.zip"
}

data "aws_ssm_parameter" "neo4j_uri" {
  name = "/ticket/neo4j/uri"
}

data "aws_ssm_parameter" "neo4j_user" {
  name = "/ticket/neo4j/user"
}

data "aws_ssm_parameter" "neo4j_password" {
  name = "/ticket/neo4j/password"
}

module "event_processor_lambda" {
  source = "../modules/lambda"

  function_name      = "search_ticket_lambda"
  runtime            = "python3.12"
  handler            = "main.main"
  filename           = data.archive_file.lambda.output_path
  timeout            = 30
  memory_size        = 256
  region             = "eu-west-1"
  enable_sqs_trigger = false
  enable_s3_access   = false

  env_variables = {
    ENVIRONMENT    = "dev"
    NEO4J_URI      = data.aws_ssm_parameter.neo4j_uri.value
    NEO4J_USER     = data.aws_ssm_parameter.neo4j_user.value
    NEO4J_PASSWORD = data.aws_ssm_parameter.neo4j_password.value
  }
}

