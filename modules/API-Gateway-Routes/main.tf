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
  target    = "integrations/${var.alb_proxy_id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt[0].id
}
