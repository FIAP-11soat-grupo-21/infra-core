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

variable "lambda_integration_id" {
  type = string
  description = "ID of the Lambda integration in API Gateway"
}
variable "api_gateway_arn" {
  description = "ARN of the API Gateway"
  type = string
  default = ""
}