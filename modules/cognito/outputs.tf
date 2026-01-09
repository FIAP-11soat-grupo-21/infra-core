output "user_pool_id" {
  description = "ID do Cognito User Pool"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "ARN do Cognito User Pool"
  value       = aws_cognito_user_pool.main.arn
}

output "user_pool_client_id" {
  description = "ID do Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.customer.id
}

output "user_pool_client_secret" {
  description = "Secret do Cognito User Pool Client (Traditional Web App)"
  value       = aws_cognito_user_pool_client.customer.client_secret
  sensitive   = true
}

output "user_pool_client_admin_id" {
  description = "ID do Cognito User Pool Client - ADMIN"
  value       = aws_cognito_user_pool_client.admin.id
}

output "user_pool_client_admin_secret" {
  description = "Secret do Cognito User Pool Client (Traditional Web App) - ADMIN"
  value       = aws_cognito_user_pool_client.admin.client_secret
  sensitive   = true
}
