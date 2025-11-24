output "service_id" {
  value = aws_ecs_service.service.id
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.tasks.arn
}

output "task_role_arn" {
  value = var.task_role_arn != "" ? var.task_role_arn : (length(aws_iam_role.ecs_task_role) > 0 ? aws_iam_role.ecs_task_role[0].arn : null)
}
