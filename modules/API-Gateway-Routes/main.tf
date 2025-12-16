resource "aws_apigatewayv2_integration" "alb_proxy" {
  api_id                 = var.api_id
  integration_type       = "HTTP_PROXY"

  integration_uri        = var.alb_listener_arn
  integration_method     = "ANY"
  payload_format_version = "1.0"

  connection_type = "VPC_LINK"
  connection_id   = var.vpc_link_id
}

resource "aws_apigatewayv2_route" "proxy" {
  api_id   = var.api_id
  route_key = var.gwapi_route_key
  target    = "integrations/${aws_apigatewayv2_integration.alb_proxy.id}"
}

resource "aws_apigatewayv2_authorizer" "jwt" {
  count = var.jwt_authorizer_enabled ? 1 : 0

  api_id          = var.api_id
  name            = var.jwt_authorizer_name
  authorizer_type = "JWT"
  identity_sources = var.jwt_identity_sources

  jwt_configuration {
    audience = var.jwt_audiences
    issuer   = var.jwt_issuer
  }
}

resource "aws_apigatewayv2_route" "restricted" {
  count = var.jwt_authorizer_enabled && try(length(var.restricted_route_key) > 0, false) ? 1 : 0

  api_id    = var.api_id
  route_key = var.restricted_route_key
  target    = "integrations/${aws_apigatewayv2_integration.alb_proxy.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt[0].id
}

resource "aws_apigatewayv2_deployment" "api_deployment" {
  api_id = var.api_id

  description = sha256(join("-", [
    aws_apigatewayv2_integration.alb_proxy.id,
    aws_apigatewayv2_route.proxy.id,
    try(aws_apigatewayv2_authorizer.jwt[0].id, ""),
    try(aws_apigatewayv2_route.restricted[0].id, ""),
  ]))

  depends_on = concat([
    aws_apigatewayv2_integration.alb_proxy,
    aws_apigatewayv2_route.proxy,
  ], aws_apigatewayv2_authorizer.jwt, aws_apigatewayv2_route.restricted)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = var.api_id
  name        = var.stage_name

  access_log_settings {
    destination_arn = var.api_gw_logs_arn
    format = jsonencode({
      requestId = "$context.requestId",
      ip = "$context.identity.sourceIp",
      caller = "$context.identity.caller",
      user = "$context.identity.user",
      requestTime = "$context.requestTime",
      httpMethod = "$context.httpMethod",
      routeKey = "$context.routeKey",
      status = "$context.status",
      protocol = "$context.protocol",
      responseLatency = "$context.responseLatency"
    })
  }

  default_route_settings {
    logging_level = "INFO"
    data_trace_enabled = true
    detailed_metrics_enabled = true
    throttling_burst_limit = 200
    throttling_rate_limit  = 1000
  }

  auto_deploy = var.gwapi_auto_deploy
  deployment_id = var.gwapi_auto_deploy ? null : (var.stage_name == "$default" ? null : aws_apigatewayv2_deployment.api_deployment.id)
}
