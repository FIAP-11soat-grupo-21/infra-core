output "api_id" {
  description = "ID da API Gateway V2"
  value       = aws_apigatewayv2_api.http_api.id
}

output "api_gateway_arn" {
  description = "ARN da API Gateway V2"
  value       = aws_apigatewayv2_api.http_api.arn
}

output "vpc_link_id" {
  description = "ID do VPC Link da API Gateway V2"
  value       = aws_apigatewayv2_vpc_link.vpc_link.id
}