output "db_connection" {
  value = aws_db_instance.database.address
}

output "db_secret_password_arn" {
  value = aws_secretsmanager_secret_version.db_credentials.arn
}