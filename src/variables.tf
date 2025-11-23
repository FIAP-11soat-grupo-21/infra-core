# Variáveis para configuração do Application Registry AWS

variable "project_name" {
  description = "Nome do projeto para o Application Registry"
  type        = string
}

variable "project_description" {
  description = "Descrição do projeto"
  type        = string
  default     = "Aplicação para o tech challenge"
}

variable "environment" {
  description = "Ambiente de implantação (ex: dev, staging, prod)"
  type        = string
  default     = "dev"
}

# Variáveis da VPC
variable "vpc_cidr" {
  description = "CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidr" {
  description = "CIDR da sub-rede privada"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_cidr" {
  description = "CIDR da sub-rede pública"
  type        = string
  default     = "10.0.2.0/24"
}

variable "ecs_container_port" {
  description = "Porta exposta pelo container"
  type        = number
  default     = 8080
}

# Variáveis do Secrets Manager
variable "secret_content" {
  description = "Conteúdo do Secret Manager em formato de mapa"
  type        = map(string)
}

# Variáveis do Load Balancer
variable "lb_name" {
    description = "Nome do Load Balancer"
    type        = string
    default     = "myapp-lb"
}

# variáveis do API Gateway
variable "gwapi_name" {
    description = "Nome da API Gateway"
    type        = string
}

variable "gwapi_stage_name" {
    description = "Nome do estágio da API Gateway"
    type        = string
    default     = "prod"
}
