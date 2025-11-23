output "table_name" {
  value = aws_dynamodb_table.this.name
}

output "table_arn" {
  value = aws_dynamodb_table.this.arn
}

output "table_stream_arn" {
  value = try(aws_dynamodb_table.this.stream_arn, null)
}

output "policy_arn" {
  value = aws_iam_policy.access_policy.arn
}

