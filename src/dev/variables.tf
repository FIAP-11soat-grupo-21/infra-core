variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "project_id" {
  description = "ID do projeto"
  type        = string
}

variable "region" {
  description = "Região onde os recursos serão criados"
  type        = string
}

variable "gke_node_vm_type" {
  description = "Tipo de máquina para os nós do GKE"
  type        = string
  default     = "e2-medium"
}

variable "gke_node_count" {
  description = "Número de nós no cluster GKE"
  type        = number
  default     = 2
}

variable "zone" {
  description = "Zona onde o cluster GKE será criado"
  type        = string
  default     = "us-central1-a"
}

variable "prefix" {
  description = "Prefixo para os recursos"
  type        = string
  default     = "fiap"
}

variable "vpc_cidr_range" {
  description = "Faixa CIDR para a VPC"
  type        = string
}

variable "vpc_auto_create_subnets" {
  description = "Indica se as sub-redes devem ser criadas automaticamente"
  type        = bool
  default     = true
}

variable "vpc_ip_ranges" {
  description = "Intervalos de IP privados para sub-redes"
  type        = list(string)
  default     = []
}

variable "openapi_path" {
    description = "Caminho para o arquivo OpenAPI"
    type        = string
    default     = "./openapi.yaml"
}

variable "vpc_connector_ip_range" {
    description = "Faixa de IP para o conector do servidor"
    type        = string
}