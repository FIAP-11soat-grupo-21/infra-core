#---------------------------------------------------------------------------------------------#
# Módulo para configurar o AWS Secrets Manager
#---------------------------------------------------------------------------------------------#

resource "random_id" "sm_random_id" {
  byte_length = 8
}

resource "aws_secretsmanager_secret" "sm" {
  name        = "${var.secret_name}-${random_id.sm_random_id.hex}"
  description = "Secret Manager para o projeto ${var.project_name}"
  tags = merge(var.project_common_tags, {
    Name = "${var.secret_name}-${random_id.sm_random_id.hex}"
  })
}

resource "aws_secretsmanager_secret_version" "sm_version" {
  secret_id     = aws_secretsmanager_secret.sm.id
  secret_string = jsonencode(var.secret_content)
}