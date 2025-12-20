variable "project_name" {
    description = "Nome do projeto para identificação dos recursos"
    type        = string
}

variable "project_common_tags" {
    description = "Tags comuns para todos os recursos do projeto"
    type        = map(string)
    default = {}
}

variable "api_name" {
  description = "Nome da API Gateway (opcional)"
  type        = string
  default     = ""
}

variable "private_subnet_ids" {
  description = "Lista de subnets privadas onde o VPC Link deve criar ENIs (deve incluir as subnets do ALB)"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ID do security group usado para permitir tráfego entre o VPC Link e o ALB"
  type        = string
}

variable "gwapi_auto_deploy" {
  type = bool
}

variable "stage_name" {
  type = string
}