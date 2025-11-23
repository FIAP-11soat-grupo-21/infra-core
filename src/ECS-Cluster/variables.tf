variable "project_name" {
  type = string
}

variable "project_common_tags" {
  type = map(string)
  default = {}
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "registry_credentials_arn" {
  type = string
}

variable "ecs_container_secrets" {
  type = map(string)
  default = {}
}

variable "project_description" {
  type = string
  default = ""
}

