data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/main.py"
  output_path = "${path.module}/lambda_function.zip"
}

module "event_processor_lambda" {
  source = "../modules/lambda"

  function_name = "lambda_function"
  runtime       = "python3.12"
  handler       = "main.main"
  filename      = data.archive_file.lambda.output_path
  timeout       = 60
  memory_size   = 256
  region        = "eu-west-1"

  enable_sqs_trigger = true
  sqs_queue_arn      = module.event_queue.queue_arn
  sqs_batch_size     = 10

  enable_s3_access = true
  s3_bucket_name   = "s3-ticket-storage"

  env_variables = {
    ENVIRONMENT = "dev"
    BUCKET_NAME = "s3-ticket-storage"
  }

}

