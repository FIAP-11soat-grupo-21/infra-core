variable "vpc_id" {
  description = "Id da VPC onde o ALB será criado"
  type        = string
}

variable "private_subnet_ids" {
  description = "Lista de IDs das subnets privadas onde o ALB será criado"
  type        = list(string)
}

variable "app_port_init_range" {
  description = "Porta de incío do range onde a aplicação está escutando"
  type        = number
  default     = 80
}

variable "app_port_end_range" {
  description = "Porta de fim do range onde a aplicação está escutando"
  type        = number
  default     = 80
}

variable "app_port" {
  description = "Porta onde a aplicação está escutando"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Caminho usado para health check no target group do ALB"
  type        = string
  default     = "/health"
}

variable "project_common_tags" {
  description = "Tags comuns para o projeto"
  type        = map(string)
  default     = {}
}

variable "loadbalancer_name" {
  description = "Nome base para o Application Load Balancer"
  type        = string
  default     = "myapp"
}

variable "is_internal" {
  description = "Define se o ALB é interno (true) ou público (false)"
  type        = bool
  default     = true
}
