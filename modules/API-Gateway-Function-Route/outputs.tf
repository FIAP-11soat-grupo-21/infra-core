output "route_id" {
  value = try(aws_apigatewayv2_route.lambda_route.id, null)
}

output "permission_statement_id" {
  value = try(aws_lambda_permission.apigw.statement_id, null)
}

