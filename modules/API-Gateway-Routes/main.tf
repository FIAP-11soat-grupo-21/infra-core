#---------------------------------------------------------------------------------------------#
# Módulo para configurar rotas do API Gateway integradas a um Application Load Balancer (ALB)
#---------------------------------------------------------------------------------------------#

#Recupera informações do API Gateway existente
data "aws_apigatewayv2_api" "api" {
  api_id = var.api_id
}

# Rotas criadas a partir do map de endpoints
resource "aws_apigatewayv2_route" "routes" {
  for_each = var.endpoints

  api_id    = var.api_id
  route_key = each.value.route_key
  target    = coalesce(each.value.target, "integrations/${var.alb_proxy_id}")

  authorization_type = each.value.restricted ? "JWT" : null
  authorizer_id      = each.value.restricted ? each.value.auth_integration_id : null
}

# Ajuste no deployment para depender de todas as rotas dinâmicas
resource "aws_apigatewayv2_deployment" "api_deployment" {
  api_id = var.api_id

  description = sha256(join("-", [
    var.alb_proxy_id,
    try(join("-", [for r in aws_apigatewayv2_route.routes : r.id]), ""),
    data.aws_apigatewayv2_api.api.name,
  ]))

  lifecycle {
    create_before_destroy = true
  }
}
