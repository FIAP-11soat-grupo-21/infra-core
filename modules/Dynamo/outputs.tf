output "table_name" {
  value = aws_dynamodb_table.table.name
}

output "table_arn" {
  value = aws_dynamodb_table.table.arn
}

output "table_stream_arn" {
  value = try(aws_dynamodb_table.table.stream_arn, null)
}

output "policy_arn" {
  value = aws_iam_policy.access_policy.arn
}

