locals {
  project_common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "application_registry" {
  source = "../modules/APP-Registry"

  project_common_tags = local.project_common_tags

  project_name        = var.project_name
  project_description = var.project_description
}

module "vcp" {
  source = "../modules/VPC"

  project_common_tags = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)

  vpc_cidr            = var.vpc_cidr
  vpc_name            = var.project_name
  private_subnet_cidr = var.private_subnet_cidr
  public_subnet_cidr  = var.public_subnet_cidr
}

module "ghcr_secret" {
  source = "../modules/SM"

  project_common_tags = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)

  project_name   = var.project_name
  secret_name    = "${var.project_name}-ghcr"
  secret_content = var.secret_content
}

module "ecs_cluster" {
  source = "../modules/ECS-Cluster"

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


module "alb" {
  source = "../modules/ALB"

  project_common_tags = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)

  vpc_id             = module.vcp.vpc_id
  private_subnet_ids = module.vcp.private_subnets

  loadbalancer_name = var.lb_name
  vpc_cidr_blocks   = [var.vpc_cidr]
  is_internal       = true
}

module "api_gateway" {
  source = "../modules/API-Gateway"

  project_common_tags = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)
  project_name        = var.project_name
  private_subnet_ids  = module.vcp.private_subnets
  alb_security_group_id = module.alb.alb_security_group_id
  api_name = var.gwapi_name
}

module "rds_postgres" {
  source = "../modules/RDS"

  project_common_tags = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)

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

module "function_bucket" {
  source = "../modules/S3"

  bucket_name = "${var.project_name}-function-bucket"
}