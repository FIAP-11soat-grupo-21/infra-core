variable "project_common_tags" {
  description = "Tags comuns do projeto"
  type        = map(string)
}

variable "db_port" {
  description = "Porta do banco de dados"
  type        = number
}

variable "db_allocated_storage" {
  description = "Armazenamento alocado para o banco de dados em GB"
  type        = number
  default     = 20
}

variable "db_storage_type" {
  description = "Tipo de armazenamento do banco de dados"
  type        = string
}

variable "db_engine" {
  description = "Motor do banco de dados (e.g., mysql, postgres)"
  type        = string
}

variable "db_engine_version" {
  description = "Versão do motor do banco de dados"
  type        = string
}

variable "db_instance_class" {
  description = "Classe da instância do banco de dados"
  type        = string
  default     = "db.t3.micro"
}

variable "db_username" {
  description = "Nome de usuário do banco de dados"
  type        = string
}

variable "private_subnets" {
  description = "Lista de sub-redes privadas para o RDS"
  type        = list(string)
}

variable "vpc_id" {
    description = "ID da VPC existente (se aplicável)"
    type        = string
}

variable "app_name" {
    description = "Nome da aplicação que irá acessar o RDS"
    type        = string
}