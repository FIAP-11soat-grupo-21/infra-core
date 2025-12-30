output "api_id" {
  description = "ID da API Gateway (entrada do módulo)."
  value       = var.api_id
}

output "api_name" {
  description = "Nome da API Gateway recuperado via data source."
  value       = data.aws_apigatewayv2_api.api.name
}

output "api_endpoint" {
  description = "Endpoint público (se aplicável) da API Gateway v2."
  value       = data.aws_apigatewayv2_api.api.api_endpoint
}

output "deployment_id" {
  description = "ID da implantação do API Gateway criada para aplicar as rotas."
  value       = aws_apigatewayv2_deployment.api_deployment.id
}

output "routes" {
  description = "Mapa com IDs das rotas criadas indexadas pela chave do mapa `endpoints`."
  value       = { for k, r in aws_apigatewayv2_route.routes : k => r.id }
}

output "authorizer_id" {
  description = "ID do autorizador JWT criado (string vazia se não criado)."
  # O módulo não cria o autorizador por padrão. Retornamos string vazia para evitar referências
  # a recursos inexistentes.
  value = ""
}
