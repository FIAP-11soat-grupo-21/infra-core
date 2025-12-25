variable "name" {
  type        = string
  default     = ""
  description = "Name of the DynamoDB table; must be provided by root via var.dynamo_name or var.dynamos entries."

  validation {
    condition     = length(var.name) > 0
    error_message = "Variable 'name' must be provided for the Dynamo module. Use var.dynamo_name in the root or define entries in var.dynamos."
  }
}

variable "billing_mode" {
  type    = string
  default = "PAY_PER_REQUEST" # or PROVISIONED
}

variable "hash_key" {
  type = string
}

variable "hash_key_type" {
  type    = string
  default = "S"
}

variable "range_key" {
  type = list(object({
    name = string,
    type = string }
  ))
  default = []
}

variable "read_capacity" {
  type    = number
  default = 5
}

variable "write_capacity" {
  type    = number
  default = 5
}

variable "global_secondary_indexes" {
  type = list(object({
    name            = string
    hash_key        = string
    range_key       = optional(string)
    projection_type = optional(string)
    read_capacity   = optional(number)
    write_capacity  = optional(number)
  }))
  default = []
}

variable "sse_enabled" {
  type    = bool
  default = false
}

variable "kms_key_arn" {
  type    = string
  default = ""
}

variable "ttl_enabled" {
  type    = bool
  default = false
}

variable "ttl_attribute" {
  type    = string
  default = ""
}

variable "stream_enabled" {
  type    = bool
  default = false
}

variable "stream_view_type" {
  type    = string
  default = "NEW_AND_OLD_IMAGES"
}

variable "pitr" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "read_only" {
  type    = bool
  default = false
}

variable "project_common_tags" {
  type    = map(string)
  default = {}
}

variable "secondary_indexes" {
  type        = list(map(string))
  default     = [{}]
  description = "List of secondary indexes to create on the DynamoDB table."
}