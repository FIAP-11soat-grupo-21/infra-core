output "lambda_arn" {
  value = aws_lambda_function.this.arn
}

output "integration_id" {
  value = try(aws_apigatewayv2_integration.lambda[0].id, null)
}

output "route_id" {
  value = try(aws_apigatewayv2_route.lambda_route[0].id, null)
}

output "vpc_subnet_ids" {
  value = var.subnet_ids
}

output "vpc_security_group_ids" {
  value = var.security_group_ids
}
