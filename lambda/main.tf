data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/main.py"
  output_path = "${path.module}/lambda_function.zip"
}

module "lambda_function" {
  source        = "../modules/lambda"
  function_name = "lambda_function"
  runtime       = "python3.12"
  region        = "us-east-1"
  handler       = "main.main"
  tags = {
    Name = "lambda_function"
  }
  filename = data.archive_file.lambda.output_path
}
