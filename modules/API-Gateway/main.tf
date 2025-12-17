resource "aws_apigatewayv2_api" "http_api" {
  name          = var.api_name != "" ? var.api_name : "${var.project_name}-http-api"
  protocol_type = "HTTP"
  tags          = var.project_common_tags

}

resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  name = "${var.project_name}-vpc-link"
  subnet_ids = var.private_subnet_ids
  security_group_ids = [var.alb_security_group_id]

  tags = var.project_common_tags
}

resource "aws_cloudwatch_log_group" "api_gw_logs" {
  name              = "/aws/apigateway/${var.api_name != "" ? var.api_name : "${var.project_name}-http-api"}"
  retention_in_days = 14
  tags = var.project_common_tags
}

