variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "app_port" {
  type    = number
  default = 80
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "project_common_tags" {
  type    = map(string)
  default = {}
}

variable "loadbalancer_name" {
  type    = string
  default = "myapp"
}

variable "vpc_cidr_blocks" {
  description = "Lista de blocos CIDR permitidos no SG do ALB (por exemplo a CIDR da VPC)"
  type        = list(string)
  default     = []
}

variable "is_internal" {
  description = "Define se o ALB é interno (true) ou público (false)"
  type        = bool
  default     = true
}
