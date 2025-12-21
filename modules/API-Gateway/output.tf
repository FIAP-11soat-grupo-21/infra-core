output "api_id" {
  description = "ID da API Gateway V2"
  value       = aws_apigatewayv2_api.http_api.id
}

output "api_endpoint" {
  description = "Endpoint base da HTTP API"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "vpc_link_id" {
  description = "ID do VPC Link criado"
  value       = aws_apigatewayv2_vpc_link.vpc_link.id
}

output "gateway_arn" {
    description = "ARN da API Gateway"
    value       = aws_apigatewayv2_api.http_api.execution_arn
}