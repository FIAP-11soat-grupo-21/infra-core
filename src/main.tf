locals {
  project_common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "application_registry" {
  source = "./APP-Registry"

  project_common_tags = local.project_common_tags

  project_name        = var.project_name
  project_description = var.project_description
}

module "vcp" {
  source = "./VPC"

  project_common_tags = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)

  vpc_cidr            = var.vpc_cidr
  vpc_name            = var.project_name
  private_subnet_cidr = var.private_subnet_cidr
  public_subnet_cidr  = var.public_subnet_cidr
}

module "rds_postgres" {
  source = "./RDS"

  project_common_tags = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)

  project_name         = var.project_name
  db_port              = var.db_port
  db_allocated_storage = var.db_allocated_storage
  db_storage_type      = var.db_storage_type
  db_engine            = var.db_engine
  db_engine_version    = var.db_engine_version
  db_instance_class    = var.db_instance_class
  db_username          = var.db_username
  private_subnets      = module.vcp.private_subnets
  vpc_id               = module.vcp.vpc_id
}

module "ghcr_secret" {
  source = "./SM"

  project_common_tags = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)

  project_name   = var.project_name
  secret_name    = "${var.project_name}-ghcr"
  secret_content = var.secret_content
}

module "alb" {
  source = "./ALB"

  project_common_tags  = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)
  project_name         = var.project_name
  vpc_id               = module.vcp.vpc_id
  private_subnet_ids   = module.vcp.private_subnets
  app_port             = var.ecs_container_port
  loadbalancer_name    = var.lb_name
  vpc_cidr_blocks      = [var.vpc_cidr]
  health_check_path    = var.ecs_health_check_path
}

module "ecs_cluster" {
  source = "./ECS-Cluster"

  depends_on = [module.ghcr_secret]

  project_common_tags = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)
  project_name        = var.project_name

  vpc_id               = module.vcp.vpc_id
  private_subnet_ids   = module.vcp.private_subnets

  registry_credentials_arn = module.ghcr_secret.secret_arn
  ecs_container_secrets     = merge(var.ecs_container_secrets, {
    DB_PASSWORD = module.rds_postgres.db_secret_password_arn
  })
}

module "ecs_api" {
  source = "./ECS-Service"

  project_common_tags = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)
  project_name        = var.project_name

  cluster_id = module.ecs_cluster.cluster_id
  ecs_security_group_id = module.ecs_cluster.ecs_security_group_id
  task_execution_role_arn = module.ecs_cluster.task_execution_role_arn
  cloudwatch_log_group = module.ecs_cluster.cloudwatch_log_group

  private_subnet_ids = module.vcp.private_subnets
  registry_credentials_arn = module.ghcr_secret.secret_arn

  ecs_container_name  = var.ecs_container_name
  ecs_container_image = var.ecs_container_image
  ecs_container_port  = var.ecs_container_port
  ecs_container_environment_variables = merge(var.ecs_container_environment_variables, {
    DB_HOST = module.rds_postgres.db_connection
  })
  ecs_container_secrets = merge(var.ecs_container_secrets, {
    DB_PASSWORD = module.rds_postgres.db_secret_password_arn
  })

  ecs_desired_count     = var.ecs_desired_count
  ecs_network_mode      = var.ecs_network_mode
  ecs_task_cpu          = var.ecs_task_cpu
  ecs_task_memory       = var.ecs_task_memory
  ecs_service_name      = var.ecs_service_name

  alb_target_group_arn   = module.alb.target_group_arn
  alb_security_group_id  = module.alb.alb_security_group_id
}

module "alb_sonarqube" {
  source = "./ALB"

  project_common_tags  = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)
  project_name         = var.project_name
  vpc_id               = module.vcp.vpc_id
  private_subnet_ids   = module.vcp.private_subnets
  app_port             = var.ecs_container_port
  loadbalancer_name    = var.alb_sonarqube_name
  vpc_cidr_blocks      = [var.vpc_cidr]
  health_check_path    = var.ecs_health_check_path
}

module "ecs_sonarqube" {
  source = "./ECS-Service"

  project_common_tags = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)
  project_name        = var.project_name

  cluster_id = module.ecs_cluster.cluster_id
  ecs_security_group_id = module.ecs_cluster.ecs_security_group_id
  task_execution_role_arn = module.ecs_cluster.task_execution_role_arn
  cloudwatch_log_group = module.ecs_cluster.cloudwatch_log_group

  private_subnet_ids = module.vcp.private_subnets

  ecs_container_name  = var.sonarqube_container_name
  ecs_container_image = var.sonarqube_container_image
  ecs_container_port  = var.sonarqube_container_port

  ecs_desired_count     = var.ecs_desired_count
  ecs_network_mode      = var.ecs_network_mode
  ecs_task_cpu          = var.ecs_task_cpu
  ecs_task_memory       = var.ecs_task_memory
  ecs_service_name      = var.sonarqube_service_name

  alb_target_group_arn   = module.alb_sonarqube.target_group_arn
  alb_security_group_id  = module.alb_sonarqube.alb_security_group_id
}

module "api_gateway" {
  source = "./API-Gateway"

  project_common_tags = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)
  project_name        = var.project_name

  private_subnet_ids  = module.vcp.private_subnets
  alb_security_group_id = module.alb.alb_security_group_id
  api_name = var.gwapi_name
}

module "api_gateway_routes" {
  source = "./API-Gateway-Routes"

  api_id = module.api_gateway.api_id
  vpc_link_id = module.api_gateway.vpc_link_id
  alb_listener_arn = module.alb.listener_arn
  gwapi_route_key = var.gwapi_route_key
  gwapi_auto_deploy = var.gwapi_auto_deploy
  stage_name = var.gwapi_stage_name
  project_common_tags = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)
  api_gw_logs_arn = module.api_gateway.api_gw_logs_arn

  depends_on = [module.alb]
}

module "dynamo" {
  source = "./Dynamo"

  project_common_tags = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)
  project_name = var.project_name

  name = var.dynamo_name != "" ? var.dynamo_name : "${var.project_name}-table"
  hash_key = var.dynamo_hash_key
  hash_key_type = var.dynamo_hash_key_type
}
