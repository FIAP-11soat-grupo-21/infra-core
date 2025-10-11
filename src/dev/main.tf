module "vpc" {
  source = "git::https://github.com/FIAP-11soat-grupo-21/infra-modules-VPC.git//src?ref=main"

  name                   = var.project_name
  region                 = var.region
  vpc_cidr_range         = var.vpc_cidr_range
  auto_create_subnets    = true
  private_ip_ranges = var.vpc_ip_ranges
  vpc_connector_ip_range = var.vpc_connector_ip_range

}

module "iam" {
  source = "git::https://github.com/FIAP-11soat-grupo-21/infra-modules-iam.git//src?ref=main"
  project_id = var.project_id
  service_accounts = {
    account_id = "gke-operator"
    roles = [
      "roles/container.admin",
      "roles/iam.workloadIdentityUser"
    ]
  }
}

module "gke" {
  source             = "git::https://github.com/FIAP-11soat-grupo-21/infra-modules-kubernetes.git//src?ref=main"
  depends_on         = [module.vpc, module.iam]
  location           = "us-central1"
  project_id         = var.project_id
  project_name       = var.project_name
  region             = var.region
  service_account_id = module.iam.service_account_email
}

module "api_gateway" {
  source     = "git::https://github.com/FIAP-11soat-grupo-21/infra-modules-api-gateway.git//src?ref=main"
  name       = var.project_name
  prefix     = "fiap"
  project_id = var.project_id
  region     = "us-central1"
  openapi_path = "./openapi.yaml"
}

module "database" {
  source              = "git::https://github.com/FIAP-11soat-grupo-21/infra-modules-database.git//src?ref=main"
  depends_on          = [module.vpc, module.iam]
  gke_service_account = module.iam.service_account_email
  project_id          = var.project_id
  project_name        = var.project_name
}