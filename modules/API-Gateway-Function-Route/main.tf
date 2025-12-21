resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke-${var.lambda_name != "" ? var.lambda_name : substr(md5(var.lambda_arn),0,8)}"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_arn}/*/*"
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = var.api_id
  route_key = var.route_key
  target    = "integrations/${var.lambda_integration_id}"
}

resource "aws_apigatewayv2_route" "proxy" {
  api_id   = var.api_id
  route_key = var.gwapi_route_key
  target    = "integrations/${var.alb_proxy_id}"
}

resource "aws_apigatewayv2_deployment" "api_deployment" {
  api_id = var.api_id

  depends_on = [
    aws_apigatewayv2_route.proxy,
  ]

  lifecycle {
    create_before_destroy = true
  }
}
