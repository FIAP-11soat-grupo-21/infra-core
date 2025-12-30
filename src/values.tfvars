# Global variables
project_name        = "fiap-tech-challenge"
project_description = "Aplicação para o tech challenge"

# VPC variables
vpc_cidr            = "10.0.0.0/16"
private_subnet_cidr = "10.0.1.0/24"
public_subnet_cidr  = "10.0.2.0/24"

# Secrets Variables
secret_content = {
  "username" : "GHCR_USERNAME",
  "password" : "GHCR_TOKEN"
}

# Load Balancer Variables
lb_name = "gateway"

# API Gateway Variables
gwapi_name       = "restaurant-api"
gwapi_stage_name = "v1"

# RDS variables
db_port              = 5432
db_allocated_storage = 20
db_engine            = "postgres"
db_storage_type      = "gp2"
db_engine_version    = "18"
db_instance_class    = "db.t3.micro"
db_username          = "adminuser"

# Cognito Variables
cognito_user_pool_name   = "restaurant-clients"
auto_verified_attributes = ["email"]
email_required           = true
name_required            = true
generate_secret          = true
access_token_validity    = 60
id_token_validity        = 60
refresh_token_validity   = 30
