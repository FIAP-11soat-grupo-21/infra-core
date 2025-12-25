variable "project_common_tags" {
  type    = map(string)
  default = {}
}

variable "cluster_id" {
  type = string
}

variable "ecs_security_group_id" {
  type = string
}

variable "task_execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type        = string
  default     = ""
  description = "(Opcional) ARN da task role que será atribuída aos containers (permite chamadas AWS a partir do app)."
}

variable "cloudwatch_log_group" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "registry_credentials_arn" {
  type    = string
  default = ""
}

variable "ecs_container_name" {
  type = string
}

variable "ecs_container_image" {
  type = string
}

variable "ecs_container_port" {
  type = number
}

variable "ecs_container_environment_variables" {
  type    = map(string)
  default = {}
}

variable "ecs_container_secrets" {
  type    = map(string)
  default = {}
}

variable "ecs_desired_count" {
  type    = number
  default = 1
}

variable "ecs_network_mode" {
  type    = string
  default = "awsvpc"
}

variable "ecs_task_cpu" {
  type    = string
  default = "256"
}

variable "ecs_task_memory" {
  type    = string
  default = "512"
}

variable "ecs_service_name" {
  type = string
}

variable "alb_target_group_arn" {
  type    = string
  default = ""
}

variable "alb_security_group_id" {
  type    = string
  default = ""
}

# Lista de ARNs de policies para anexar à task role (criadas pelo módulo ou fornecida via task_role_arn)
variable "task_role_policy_arns" {
  type        = list(string)
  default     = []
  description = "(Opcional) Lista de ARNs de IAM policies para anexar à task role usada pelos containers."
}
