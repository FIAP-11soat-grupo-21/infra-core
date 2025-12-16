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

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the Lambda security group will be created."

  validation {
    condition     = length(var.vpc_id) > 0
    error_message = "You must provide a valid VPC ID for creating the Lambda security group."
  }
}
