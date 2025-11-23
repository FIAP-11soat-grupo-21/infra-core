variable "vpc_cidr" {
  description = "Bloco CIDR para a VPC principal"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
    description = "Nome da VPC"
    type        = string
    default     = "main-vpc"
}

variable "project_common_tags" {
    description = "Tags comuns para todos os recursos do projeto"
    type        = map(string)
    default = {}
}

variable "private_subnet_cidr" {
    description = "Bloco CIDR para a sub-rede privada"
    type        = string
    default     = "10.0.1.0/24"
}

variable "public_subnet_cidr" {
    description = "Bloco CIDR para a sub-rede pública"
    type        = string
    default     = "10.0.2.0/24"
}