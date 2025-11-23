output "integration_id" {
  value = try(aws_apigatewayv2_integration.lambda[0].id, null)
}

output "route_id" {
  value = try(aws_apigatewayv2_route.lambda_route[0].id, null)
}

output "permission_statement_id" {
  value = try(aws_lambda_permission.apigw[0].statement_id, null)
}

