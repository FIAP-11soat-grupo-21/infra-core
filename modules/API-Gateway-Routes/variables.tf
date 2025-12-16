// filepath: c:\Users\mateu\GolandProjects\infra\API-Gateway-Routes\variables.tf
variable "api_id" { type = string }
variable "vpc_link_id" { type = string }
variable "alb_listener_arn" { type = string }
variable "gwapi_route_key" { type = string }
variable "gwapi_auto_deploy" { type = bool }
variable "stage_name" { type = string }
variable "project_common_tags" { type = map(string) }
variable "api_gw_logs_arn" { type = string }

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
