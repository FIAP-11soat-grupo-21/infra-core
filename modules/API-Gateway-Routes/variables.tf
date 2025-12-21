// filepath: c:\Users\mateu\GolandProjects\infra\API-Gateway-Routes\variables.tf
variable "api_id" { type = string }

// Optional JWT authorizer and restricted route
variable "jwt_authorizer_enabled" {
  type    = bool
  default = false
}

variable "jwt_authorizer_name" {
  type    = string
  default = "jwt-authorizer"
}

variable "jwt_issuer" {
  type    = string
  default = null
}

variable "jwt_audiences" {
  type    = list(string)
  default = []
}

variable "jwt_identity_sources" {
  type    = list(string)
  default = ["$request.header.Authorization"]
}

variable "restricted_route_key" {
  description = "Opcional: rota que exigirá JWT (ex: 'GET /restricted' ou 'ANY /secure/{proxy+}')"
  type        = string
  default     = null
}

variable "alb_proxy_id" {
  type = string
  description = "Id do proxy de integração do ALB criado no módulo ALB-API-Gateway"
}