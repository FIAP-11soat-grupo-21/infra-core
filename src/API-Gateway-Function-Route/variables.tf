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

variable "payload_format_version" {
  description = "Payload format version for the integration"
  type = string
  default = "2.0"
}

variable "project_common_tags" {
  type = map(string)
  default = {}
}

