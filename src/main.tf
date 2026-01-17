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

  project_name       = var.project_name
  vpc_id             = module.vcp.vpc_id
  private_subnet_ids = module.vcp.private_subnets
}

module "alb" {
  source = "../modules/ALB"

  project_common_tags = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)

  vpc_id              = module.vcp.vpc_id
  private_subnet_ids  = module.vcp.private_subnets
  loadbalancer_name   = var.lb_name
  is_internal         = true
  app_port_init_range = 8080
  app_port_end_range  = 8090
}

module "api_gateway" {
  source = "../modules/API-Gateway"

  project_common_tags = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)

  project_name          = var.project_name
  private_subnet_ids    = module.vcp.private_subnets
  alb_security_group_id = module.alb.alb_security_group_id
  api_name              = var.gwapi_name
  gwapi_auto_deploy     = true
  stage_name            = "v1"
}

module "cognito" {
  source = "../modules/cognito"

  user_pool_name               = var.cognito_user_pool_name
  allow_admin_create_user_only = var.allow_admin_create_user_only
  auto_verified_attributes     = var.auto_verified_attributes
  username_attributes          = var.username_attributes
  email_required               = var.email_required
  name_required                = var.name_required
  generate_secret              = var.generate_secret
  access_token_validity        = var.access_token_validity
  id_token_validity            = var.id_token_validity
  refresh_token_validity       = var.refresh_token_validity

  tags = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)
}

module "RDS" {
  source               = "../modules/RDS"
  project_common_tags  = { Project = var.project_name }
  app_name             = "${var.project_name}-${var.db_engine}-db"
  db_port              = var.db_port
  db_allocated_storage = var.db_allocated_storage
  db_storage_type      = "gp2"
  db_engine            = var.db_engine
  db_engine_version    = var.db_engine_version
  db_instance_class    = var.db_instance_class
  db_username          = var.db_username

  private_subnets = module.vcp.private_subnets
  vpc_id          = module.vcp.vpc_id
}

resource "aws_sns_topic" "order_error_topic" {
  name = "order-error"
  tags = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)
}

resource "aws_sns_topic" "order_status_topic" {
  name = "order-status"
  tags = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)
}

resource "aws_sns_topic" "payment_processed_topic" {
  name = "payment-processed"
  tags = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)
}

resource "aws_sns_topic" "kitchen_order_topic" {
  name = "kitchen-order-finished"
  tags = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)
}

resource "aws_sns_topic" "order_created_topic" {
  name = "order-created"
  tags = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)
}

module "sqs_create_payment" {
  source = "../modules/SQS"

  queue_name             = "create-payment-queue"
  project_common_tags    = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)
  allowed_sns_topic_arns = [aws_sns_topic.order_created_topic.arn]
}

module "sqs_create_kitchen_order" {
  source = "../modules/SQS"

  queue_name             = "create-kitchen-order-queue"
  project_common_tags    = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)
  allowed_sns_topic_arns = [aws_sns_topic.payment_processed_topic.arn]
}

module "sqs_update_order_status" {
  source = "../modules/SQS"

  queue_name             = "update-order-status-queue"
  project_common_tags    = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)
  allowed_sns_topic_arns = [aws_sns_topic.payment_processed_topic.arn, aws_sns_topic.kitchen_order_topic.arn]
}

module "sqs_order_error" {
  source = "../modules/SQS"

  queue_name             = "order-order-error-queue"
  project_common_tags    = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)
  allowed_sns_topic_arns = [aws_sns_topic.order_error_topic.arn]
}

module "sqs_kitchen-order-order-error" {
  source = "../modules/SQS"

  queue_name             = "kitchen-order-order-error-queue"
  project_common_tags    = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)
  allowed_sns_topic_arns = [aws_sns_topic.order_error_topic.arn]
}

module "sqs_payment-order-error" {
  source = "../modules/SQS"

  queue_name             = "payment-order-error-queue"
  project_common_tags    = merge(local.project_common_tags, module.application_registry.app_registry_application_tag)
  allowed_sns_topic_arns = [aws_sns_topic.order_error_topic.arn]
}

resource "aws_sns_topic_subscription" "order_created_to_create_payment" {
  topic_arn  = aws_sns_topic.order_created_topic.arn
  protocol   = "sqs"
  endpoint   = module.sqs_create_payment.sqs_queue_arn
  depends_on = [module.sqs_create_payment]
}

resource "aws_sns_topic_subscription" "payment_processed_to_create_kitchen_order" {
  topic_arn  = aws_sns_topic.payment_processed_topic.arn
  protocol   = "sqs"
  endpoint   = module.sqs_create_kitchen_order.sqs_queue_arn
  depends_on = [module.sqs_create_kitchen_order]
}

resource "aws_sns_topic_subscription" "payment_processed_to_update_order_status" {
  topic_arn  = aws_sns_topic.payment_processed_topic.arn
  protocol   = "sqs"
  endpoint   = module.sqs_update_order_status.sqs_queue_arn
  depends_on = [module.sqs_update_order_status]
}

resource "aws_sns_topic_subscription" "kitchen_order_to_update_order_status" {
  topic_arn  = aws_sns_topic.kitchen_order_topic.arn
  protocol   = "sqs"
  endpoint   = module.sqs_update_order_status.sqs_queue_arn
  depends_on = [module.sqs_update_order_status]
}

resource "aws_sns_topic_subscription" "order_error_to_order_error_queue" {
  topic_arn  = aws_sns_topic.order_error_topic.arn
  protocol   = "sqs"
  endpoint   = module.sqs_order_error.sqs_queue_arn
  depends_on = [module.sqs_order_error]
}

resource "aws_sns_topic_subscription" "order_error_to_kitchen_order_error_queue" {
  topic_arn  = aws_sns_topic.order_error_topic.arn
  protocol   = "sqs"
  endpoint   = module.sqs_kitchen-order-order-error.sqs_queue_arn
  depends_on = [module.sqs_kitchen-order-order-error]
}

resource "aws_sns_topic_subscription" "order_error_to_payment_order_error_queue" {
  topic_arn  = aws_sns_topic.order_error_topic.arn
  protocol   = "sqs"
  endpoint   = module.sqs_payment-order-error.sqs_queue_arn
  depends_on = [module.sqs_payment-order-error]
}
