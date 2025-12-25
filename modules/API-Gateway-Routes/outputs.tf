output "api_id" {
  description = "ID da API Gateway (entrada do módulo)."
  value       = var.api_id
}

output "api_name" {
  description = "Nome da API Gateway recuperado via data source."
  value       = data.aws_apigatewayv2_api.gateway_api.name
}

output "api_endpoint" {
  description = "Endpoint público (se aplicável) da API Gateway v2."
  value       = data.aws_apigatewayv2_api.gateway_api.api_endpoint
}

output "route_proxy_id" {
  description = "ID da rota proxy criada pelo módulo (`aws_apigatewayv2_route.proxy`)."
  value       = aws_apigatewayv2_route.proxy.id
}

output "route_restricted_id" {
  description = "ID da rota restrita protegida por JWT (string vazia se não criada)."
  value       = try(aws_apigatewayv2_route.restricted[0].id, "")
}

output "deployment_id" {
  description = "ID da implantação do API Gateway criada para aplicar as rotas."
  value       = aws_apigatewayv2_deployment.api_deployment.id
}

output "authorizer_id" {
  description = "ID do autorizador JWT criado (string vazia se não criado)."
  value       = try(aws_apigatewayv2_authorizer.jwt[0].id, "")
}

