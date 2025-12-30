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

# Variáveis do RDS (adicionadas)
variable "db_port" {
  description = "Porta do banco de dados"
  type        = number
  default     = 5432
}

variable "db_allocated_storage" {
  description = "Tamanho do storage alocado (GB) para a instância RDS"
  type        = number
  default     = 20
}

variable "db_storage_type" {
  description = "Tipo de storage para RDS (gp2, gp3, io1, padrão: gp2)"
  type        = string
  default     = "gp2"
}

variable "db_engine" {
  description = "Engine do banco de dados (ex: postgres, mysql)"
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "Versão do engine do banco de dados"
  type        = string
  default     = "13.7"
}

variable "db_instance_class" {
  description = "Classe da instância RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "db_username" {
  description = "Nome do usuário administrador do banco"
  type        = string
  default     = "postgres"
}


##########################################################
############ Variáveis do Cognito User Pool ##############
##########################################################

variable "cognito_user_pool_name" {
  description = "Nome do Cognito User Pool"
  type        = string
  default     = "tech-challenge-user-pool"
}

variable "allow_admin_create_user_only" {
  description = "Permitir apenas criação de usuário por admin"
  type        = bool
  default     = false
}

variable "auto_verified_attributes" {
  description = "Atributos auto verificados"
  type        = list(string)
  default     = ["email"]
}

variable "username_attributes" {
  description = "Atributos usados como username"
  type        = list(string)
  default     = []
}

variable "email_required" {
  description = "E-mail é requerido"
  type        = bool
  default     = true
}

variable "name_required" {
  description = "Nome é requerido"
  type        = bool
  default     = true
}

variable "generate_secret" {
  description = "Gerar secret para o client"
  type        = bool
  default     = true
}

variable "access_token_validity" {
  description = "Validade do access token em minutos"
  type        = number
  default     = 60
}

variable "id_token_validity" {
  description = "Validade do id token em minutos"
  type        = number
  default     = 60
}

variable "refresh_token_validity" {
  description = "Validade do refresh token em dias"
  type        = number
  default     = 30
}
