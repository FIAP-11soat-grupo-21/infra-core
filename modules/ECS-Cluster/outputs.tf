output "cluster_id" {
  value = aws_ecs_cluster.cluster.id
}

output "cluster_arn" {
  value = aws_ecs_cluster.cluster.arn
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs_sg.id
}

output "kms_key_arn" {
  value = aws_kms_key.kms_key.arn
}

output "cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.logs.name
}

output "task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "secretsmanager_vpc_endpoint_id" {
  value = aws_vpc_endpoint.secretsmanager_endpoint.id
}

output "kms_vpc_endpoint_id" {
  value = aws_vpc_endpoint.kms_endpoint.id
}

