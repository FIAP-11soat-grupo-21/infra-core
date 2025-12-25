#---------------------------------------------------------------------------------------------#
# Módulo para configurar o API Gateway HTTP integrado a um Application Load Balancer (ALB)
#---------------------------------------------------------------------------------------------#

# Criação do API Gateway HTTP
resource "aws_apigatewayv2_api" "http_api" {
  name          = var.api_name != "" ? var.api_name : "${var.project_name}-http-api"
  protocol_type = "HTTP"
  tags          = var.project_common_tags

}

# Criação do VPC Link para conectar o API Gateway ao ALB
resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  name               = "${var.project_name}-vpc-link"
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [var.alb_security_group_id]

  tags = var.project_common_tags
}

# Criação do grupo de logs do CloudWatch para o API Gateway
resource "aws_cloudwatch_log_group" "api_gw_logs" {
  name              = "/aws/apigateway/${var.api_name != "" ? var.api_name : "${var.project_name}-http-api"}"
  retention_in_days = 14
  tags              = var.project_common_tags
}

# Criação do estágio do API Gateway com configurações de log e métricas
resource "aws_apigatewayv2_stage" "api_stage" {
  api_id = aws_apigatewayv2_api.http_api.id
  name   = var.stage_name

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_logs.arn
    format = jsonencode({
      requestId       = "$context.requestId",
      ip              = "$context.identity.sourceIp",
      caller          = "$context.identity.caller",
      user            = "$context.identity.user",
      requestTime     = "$context.requestTime",
      httpMethod      = "$context.httpMethod",
      routeKey        = "$context.routeKey",
      status          = "$context.status",
      protocol        = "$context.protocol",
      responseLatency = "$context.responseLatency"
    })
  }

  default_route_settings {
    logging_level            = "INFO"
    data_trace_enabled       = true
    detailed_metrics_enabled = true
    throttling_burst_limit   = 200
    throttling_rate_limit    = 1000
  }

  auto_deploy = var.gwapi_auto_deploy
}