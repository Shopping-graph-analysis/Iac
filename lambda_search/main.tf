data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/main.py"
  output_path = "${path.module}/lambda_function.zip"
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
    ENVIRONMENT = "dev"
  }
}

