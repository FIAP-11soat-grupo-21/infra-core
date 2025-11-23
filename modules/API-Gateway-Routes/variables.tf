// filepath: c:\Users\mateu\GolandProjects\infra\API-Gateway-Routes\variables.tf
variable "api_id" { type = string }
variable "vpc_link_id" { type = string }
variable "alb_listener_arn" { type = string }
variable "gwapi_route_key" { type = string }
variable "gwapi_auto_deploy" { type = bool }
variable "stage_name" { type = string }
variable "project_common_tags" { type = map(string) }
variable "api_gw_logs_arn" { type = string }

