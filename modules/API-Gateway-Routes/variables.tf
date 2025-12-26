variable "api_id" { type = string }

variable "jwt_authorizer_name" {
  type    = string
  default = "jwt-authorizer"
}

variable "endpoints" {
  description = "Map de endpoints: chave => object({ route_key = string, target = optional(string), restricted = optional(bool) })"
  type = map(object({
    route_key = string
    target    = optional(string)
    restricted = optional(bool, false)
    auth_integration_id = optional(string)
  }))
}

variable "alb_proxy_id" {
  type = string
  description = "Id do proxy de integração do ALB criado no módulo ALB-API-Gateway"
}