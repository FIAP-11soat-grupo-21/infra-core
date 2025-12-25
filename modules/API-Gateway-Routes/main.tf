#---------------------------------------------------------------------------------------------#
# Módulo para configurar rotas do API Gateway integradas a um Application Load Balancer (ALB)
#---------------------------------------------------------------------------------------------#

#Recupera informações do API Gateway existente
data "aws_apigatewayv2_api" "gateway_api" {
  api_id = var.api_id
}

locals {
  # Referência ao data source para evitar warning de 'data source is never used'.
  api_name     = data.aws_apigatewayv2_api.gateway_api.name
  api_endpoint = data.aws_apigatewayv2_api.gateway_api.api_endpoint
}

# Integração do API Gateway com o ALB
resource "aws_apigatewayv2_route" "proxy" {
  api_id    = var.api_id
  route_key = var.gwapi_route_key
  target    = "integrations/${var.alb_proxy_id}"
}

# Cria uma implantação do API Gateway para aplicar as alterações nas rotas
resource "aws_apigatewayv2_deployment" "api_deployment" {
  api_id = var.api_id

  description = sha256(join("-", [
    var.alb_proxy_id,
    aws_apigatewayv2_route.proxy.id,
    try(aws_apigatewayv2_authorizer.jwt[0].id, ""),
    try(aws_apigatewayv2_route.restricted[0].id, ""),
    # Referência ao nome da API (data source) para assegurar que o data source é usado
    local.api_name,
  ]))

  depends_on = [
    aws_apigatewayv2_route.proxy,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# Configuração do autorizador JWT, se habilitado
resource "aws_apigatewayv2_authorizer" "jwt" {
  count = var.jwt_authorizer_enabled ? 1 : 0

  api_id           = var.api_id
  name             = var.jwt_authorizer_name
  authorizer_type  = "JWT"
  identity_sources = var.jwt_identity_sources

  jwt_configuration {
    audience = var.jwt_audiences
    issuer   = var.jwt_issuer
  }
}

# Rota restrita protegida por autorizador JWT, se habilitado e especificado
resource "aws_apigatewayv2_route" "restricted" {
  count = var.jwt_authorizer_enabled && try(length(var.restricted_route_key) > 0, false) ? 1 : 0

  api_id    = var.api_id
  route_key = var.restricted_route_key
  target    = "integrations/${var.alb_proxy_id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt[0].id
}
