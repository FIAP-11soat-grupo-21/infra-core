module "vpc" {
  source = "git::https://github.com/FIAP-11soat-grupo-21/infra-modules-VPC.git//src?ref=main"

  name = "restaurant"
  region = "us-central-1"
  vpc_cidr_range = "10.0.0.0/24"
  vpc_connector_ip_range = "10.8.0.0/28"
  private_ip_ranges = ["10.0.1.0/24"]
  auto_create_subnets = true
}

module "iam" {
  source = "git::https://github.com/FIAP-11soat-grupo-21/infra-modules-iam.git//src?ref=main"

  service_accounts = {
    account_id = "gke-operator"
    roles = [
      "roles/container.admin",
      "roles/iam.serviceAccountUser",
      "roles/compute.networkAdmin",
      "roles/compute.securityAdmin",
      "roles/monitoring.metricWriter",
      "roles/logging.logWriter"
    ]
  }
}


module "gke" {
  source             = "git::https://github.com/FIAP-11soat-grupo-21/infra-modules-kubernetes.git//src?ref=main"
  depends_on = [module.vpc, module.iam]
  location           = "us-central-1-a"
  project_id         = "fiap-prj-fast-food"
  project_name       = "restaurant"
  region             = "us-central-1"
  service_account_id = module.iam.service_account_id
}

module "api_gateway" {
  source = "git::https://github.com/FIAP-11soat-grupo-21/infra-modules-api-gateway.git//src?ref=main"
  name   = "restaurant"
  prefix = "fiap"
  project_id = "fiap-prj-fast-food"
  region = "us-central-1"
}

module "database" {
  source = "git::https://github.com/FIAP-11soat-grupo-21/infra-modules-database.git//src?ref=main"
  depends_on = [module.vpc, module.iam]
  gke_service_account = module.iam.service_account_id
  project_id = "fiap-prj-fast-food"
}