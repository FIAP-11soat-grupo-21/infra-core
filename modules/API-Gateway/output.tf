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

output "api_endpoint" {
  description = "URL base do API Gateway (invoke URL)"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "api_invoke_url" {
  description = "URL completa do API Gateway incluindo o stage"
  value       = "${aws_apigatewayv2_api.http_api.api_endpoint}/${aws_apigatewayv2_stage.api_stage.name}"
}