variable "api_id" {
  description = "API Gateway v2 API id"
  type = string
  default = ""
}

variable "route_key" {
  description = "Route key for API (e.g. 'GET /path' or '$default')"
  type = string
  default = ""
}

variable "lambda_arn" {
  description = "ARN of the Lambda function to integrate"
  type = string
  default = ""
}

variable "lambda_name" {
  description = "Optional friendly name used for the lambda when composing statement_id"
  type = string
  default = ""
}

variable "project_common_tags" {
  type = map(string)
  default = {}
}
variable "api_gateway_arn" {
  description = "ARN of the API Gateway"
  type = string
  default = ""
}
variable "alb_proxy_id" {
  type        = string
  description = "Id do proxy de integração do ALB criado no módulo ALB-API-Gateway"
}

variable "gwapi_route_key" {
  description = "Route key for the ALB proxy route (e.g. 'GET /{proxy+}' or 'ANY /{proxy+}')"
  type = string
}

variable "lambda_integration_id" {
    description = "Integration ID for the Lambda function"
    type = string
}