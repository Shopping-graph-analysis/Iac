locals {
  role_name = "${var.function_name}_lambda_execution_role"
}

data "aws_s3_bucket" "ticket_ingestion_bucket" {
  bucket = var.s3_bucket_name
}

data "aws_sqs_queue" "ticket_ingestion_queue" {
  name = var.sqs_queue_name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "lambda_s3_policy" {
  count       = var.enable_s3_access ? 1 : 0
  name        = "${var.function_name}_s3_access"
  description = "Allow Lambda to read from S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          data.aws_s3_bucket.ticket_ingestion_bucket.arn,
          "${data.aws_s3_bucket.ticket_ingestion_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  count      = var.enable_s3_access ? 1 : 0
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy[0].arn
}

resource "aws_iam_policy" "lambda_sqs_policy" {
  count       = var.enable_sqs_trigger ? 1 : 0
  name        = "${var.function_name}_sqs_access"
  description = "Allow Lambda to consume SQS messages"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = data.aws_sqs_queue.ticket_ingestion_queue.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_policy_attachment" {
  count      = var.enable_sqs_trigger ? 1 : 0
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_sqs_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "lambda_function" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_execution_role.arn
  runtime       = var.runtime
  filename      = var.filename
  handler       = var.handler
  timeout       = var.timeout
  memory_size   = var.memory_size

  environment {
    variables = var.env_variables
  }

  tags = var.tags
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  count            = var.enable_sqs_trigger ? 1 : 0
  event_source_arn = data.aws_sqs_queue.ticket_ingestion_queue.arn
  function_name    = aws_lambda_function.lambda_function.arn
  batch_size       = var.sqs_batch_size
  enabled          = true
  depends_on       = [aws_iam_role_policy_attachment.lambda_sqs_policy_attachment]
}
