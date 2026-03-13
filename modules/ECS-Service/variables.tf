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

variable "enable_ecs_autoscaling" {
  type        = bool
  default     = false
  description = "Enable ECS service autoscaling using target tracking policies for CPU and memory."
}

variable "ecs_autoscaling_min_capacity" {
  type        = number
  default     = 1
  description = "Minimum number of tasks for ECS service autoscaling."
}

variable "ecs_autoscaling_max_capacity" {
  type        = number
  default     = 4
  description = "Maximum number of tasks for ECS service autoscaling."

  validation {
    condition     = var.ecs_autoscaling_max_capacity >= var.ecs_autoscaling_min_capacity
    error_message = "ecs_autoscaling_max_capacity must be greater than or equal to ecs_autoscaling_min_capacity."
  }
}

variable "ecs_autoscaling_cpu_target" {
  type        = number
  default     = 70
  description = "CPU utilization target percentage for ECS autoscaling policy."

  validation {
    condition     = var.ecs_autoscaling_cpu_target > 0 && var.ecs_autoscaling_cpu_target <= 100
    error_message = "ecs_autoscaling_cpu_target must be between 1 and 100."
  }
}

variable "ecs_autoscaling_memory_target" {
  type        = number
  default     = 75
  description = "Memory utilization target percentage for ECS autoscaling policy."

  validation {
    condition     = var.ecs_autoscaling_memory_target > 0 && var.ecs_autoscaling_memory_target <= 100
    error_message = "ecs_autoscaling_memory_target must be between 1 and 100."
  }
}

variable "ecs_autoscaling_scale_in_cooldown" {
  type        = number
  default     = 60
  description = "Cooldown in seconds after scale in actions."
}

variable "ecs_autoscaling_scale_out_cooldown" {
  type        = number
  default     = 60
  description = "Cooldown in seconds after scale out actions."
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
