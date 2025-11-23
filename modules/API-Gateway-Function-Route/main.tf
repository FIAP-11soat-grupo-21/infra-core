// Module: API-Gateway-Function-Route
// Creates an AWS API Gateway v2 integration and route for invoking a Lambda function

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  create_integration = var.api_id != "" && var.lambda_arn != "" && var.route_key != ""
}

resource "aws_lambda_permission" "apigw" {
  count         = local.create_integration ? 1 : 0
  statement_id  = "AllowAPIGatewayInvoke-${var.lambda_name != "" ? var.lambda_name : substr(md5(var.lambda_arn),0,8)}"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = local.create_integration ? "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.api_id}/*/*/*" : null
}

resource "aws_apigatewayv2_integration" "lambda" {
  count                  = local.create_integration ? 1 : 0
  api_id                 = var.api_id
  integration_type       = "AWS_PROXY"
  integration_uri        = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.lambda_arn}/invocations"
  integration_method     = "POST"
  payload_format_version = var.payload_format_version

  depends_on = [aws_lambda_permission.apigw]
}

resource "aws_apigatewayv2_route" "lambda_route" {
  count     = local.create_integration ? 1 : 0
  api_id    = var.api_id
  route_key = var.route_key
  target    = "integrations/${aws_apigatewayv2_integration.lambda[0].id}"

  depends_on = [aws_apigatewayv2_integration.lambda]
}

