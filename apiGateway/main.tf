data "aws_lambda_function" "search" {
  function_name = "lambda_function"
  region        = "eu-west-1"
}

module "api_gateway" {
  source          = "../modules/apiGateway"
  api_name        = "graph_api_gateway"
  api_description = "API Gateway for shopping graph analysis"
  api_stage_name  = "dev"
  endpoints = {
    search = {
      path_part            = "search"
      method               = "GET"
      lambda_invoke_arn    = data.aws_lambda_function.search.invoke_arn
      lambda_function_name = data.aws_lambda_function.search.function_name
    }
  }
}
