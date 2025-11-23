variable "lambda_name" {
  type = string
}

variable "source_path" {
  type        = string
  description = "Path to lambda source directory to be zipped by data.archive_file"
}

variable "handler" {
  type    = string
  default = "handler.handler"
}

variable "runtime" {
  type    = string
  default = "python3.9"
}

variable "environment" {
  type    = map(string)
  default = {}
}

variable "subnet_ids" {
  type = list(string)
  description = "Subnet IDs where Lambda should be placed (required for VPC access)."

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet ID must be provided so the Lambda function is placed inside the VPC."
  }
}

variable "security_group_ids" {
  type = list(string)
  description = "Security group IDs for Lambda function (required for VPC access)."

  validation {
    condition     = length(var.security_group_ids) > 0
    error_message = "At least one security group ID must be provided so the Lambda function has network access in the VPC."
  }
}

variable "api_id" {
  type    = string
  default = ""
  description = "apigatewayv2 API id where route/integration will be created (optional)."
}

variable "route_key" {
  type    = string
  default = ""
  description = "API route key, e.g. \"GET /path\" or \"$default\" (optional)."
}

variable "secrets_arn" {
  type    = string
  default = null
}

variable "allow_dynamodb_access" {
  type    = bool
  default = false
}

variable "dynamo_table_arn" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
