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

variable "layer_enabled" {
  description = "Enable creation and attachment of a Lambda Layer"
  type        = bool
  default     = false
}

variable "layer_source_path" {
  description = "Path to the layer source directory to be zipped (folder content will be the layer content)"
  type        = string
  default     = ""
}

variable "layer_name" {
  description = "Name for the Lambda Layer"
  type        = string
  default     = ""
}

variable "layer_compatible_runtimes" {
  description = "List of runtimes compatible with the layer"
  type        = list(string)
  default     = []
}

variable "layer_compatible_architectures" {
  description = "List of architectures compatible with the layer (e.g. x86_64, arm64)"
  type        = list(string)
  default     = []
}

variable "layer_description" {
  description = "Optional description for the layer"
  type        = string
  default     = ""
}

variable "layer_license_info" {
  description = "Optional license info for the layer"
  type        = string
  default     = ""
}
