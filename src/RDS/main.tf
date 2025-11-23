data "aws_region" "current" {}

data "aws_prefix_list" "s3"{
    filter {
      name = "prefix-list-name"
      values = ["com.amazonaws.${data.aws_region.current.region}.s3"]
    }
}

# Configuração de grupo de segurança para o RDS
resource "aws_db_subnet_group" "rds" {
  description = "security group para o rds ${var.db_engine}"
  subnet_ids = var.private_subnets

  tags = merge(var.project_common_tags, {
    Name = "sg-${var.db_engine}-rds"
  })
}

# Configuração da regra
resource "aws_security_group" "rds_allow_app" {
  name  = "${var.db_engine}-rds-allow-app"
  description = "Allow access to RDS from application servers"
  vpc_id = var.vpc_id

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Configuração da instância do RDS
resource "aws_db_instance" "database" {
  depends_on = [random_password.db_password]

  identifier           = var.db_engine
  allocated_storage    = var.db_allocated_storage
  storage_type         = var.db_storage_type
  engine               = var.db_engine
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  username             = var.db_username
  password             = random_password.db_password.result
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.rds_allow_app.id]
  db_subnet_group_name = aws_db_subnet_group.rds.name

  tags = merge(var.project_common_tags, {
    Name = "${var.project_name}-${var.db_engine}-db"
  })
}

# Senha gerada para o banco de dados
resource "random_password" "db_password" {
    length  = 14
    special = false
}

resource "random_id" "secret_suffix" {
  byte_length = 4
}

# Criar secret no secret manager
resource "aws_secretsmanager_secret" "db_credentials" {
    name = "${var.db_engine}-${random_id.secret_suffix.hex}-db-password"
    description = "Senha do banco de dados ${var.db_engine} para o projeto ${var.project_name}"
    tags = var.project_common_tags
}

# Configuração de secret manager
resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = random_password.db_password.result
}