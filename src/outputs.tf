output "ecs_cluster_id" {
  description = "ECS cluster id"
  value       = module.ecs_cluster.cluster_id
}

output "ecs_security_group_id" {
  description = "Security group ID usado pelas tasks ECS"
  value       = module.ecs_cluster.ecs_security_group_id
}

output "ecs_cloudwatch_log_group" {
  description = "CloudWatch log group usado pelo ECS"
  value       = module.ecs_cluster.cloudwatch_log_group
}

output "ecs_task_execution_role_arn" {
  description = "ARN da task execution role do ECS"
  value       = module.ecs_cluster.task_execution_role_arn
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = module.vcp.private_subnets
}

output "vpc_id" {
  description = "VPC id"
  value       = module.vcp.vpc_id
}

output "vpc_cdir_block" {
  description = "VPC id"
  value       = module.vcp.cdir_block
}

output "private_subnet_id" {
  description = "ID da subnet privada (retorna a lista para compatibilidade)"
  value       = module.vcp.private_subnets
}

output "project_name" {
  description = "Nome do projeto"
  value       = var.project_name
}

output "project_common_tags" {
  description = "Tags comuns do projeto"
  value       = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)
}

output "alb_target_group_arn" {
  description = "ARN do target group do ALB"
  value       = module.alb.target_group_arn
}

output "alb_arn" {
  description = "ARN do ALB"
  value       = module.alb.alb_arn
}

output "alb_security_group_id" {
  description = "ID do security group do ALB"
  value       = module.alb.alb_security_group_id
}

output "alb_listener_arn" {
  value = module.alb.listener_arn
}

output "api_gateway_id" {
  description = "ID da API Gateway (v2)"
  value       = module.api_gateway.api_id
}

output "api_gateway_vpc_link_id" {
  description = "ID do VPC Link da API Gateway"
  value       = module.api_gateway.vpc_link_id
}

output "api_gateway_stage_name" {
  description = "Nome do estágio da API Gateway (configurado via gwapi_stage_name)"
  value       = var.gwapi_stage_name
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group usado pelo ECS"
  value       = module.ecs_cluster.cloudwatch_log_group
}

output "rds_postgres_db_username" {
  description = "Usuário do banco de dados (configurado via variável db_username)"
  value       = var.db_username
}

output "rds_address" {
  value = module.RDS.db_connection
}

output "rds_secret_arn" {
  value = module.RDS.db_secret_password_arn
}

output "ecr_registry_credentials_arn" {
  description = "Credencial do GHCR"
  value       = module.ghcr_secret.secret_arn
}

output "api_gateway_arn" {
  description = "ARN da API Gateway"
  value       = module.api_gateway.api_gateway_arn
}

output "cognito_user_pool_id" {
  description = "ID do Cognito User Pool"
  value       = module.cognito.user_pool_id
}

output "cognito_user_pool_arn" {
  description = "ARN do Cognito User Pool"
  value       = module.cognito.user_pool_arn
}

output "cognito_user_pool_client_id" {
  description = "ID do Cognito User Pool Client"
  value       = module.cognito.user_pool_client_id
}

output "cognito_user_pool_client_secret" {
  description = "Secret do Cognito User Pool Client (Traditional Web App)"
  value       = module.cognito.user_pool_client_secret
  sensitive   = true
}
