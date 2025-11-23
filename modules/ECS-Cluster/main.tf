data "aws_region" "current" {}

# Cria chave do KMS para uso em tarefas ECS e grupo de logs do CloudWatch
resource "aws_kms_key" "kms_key" {
  description             = "KMS key for ECS tasks in project ${var.project_name}"
  deletion_window_in_days = 7

  tags = merge(var.project_common_tags, {
      Name = "${var.project_name}-ecs-kms-key"
  })
}

# Cria grupo de logs do CloudWatch para uso em tarefas ECS
resource "aws_cloudwatch_log_group" "logs" {
  name             = "/ecs/${var.project_name}-logs"
  retention_in_days = 30

  tags = merge(var.project_common_tags, {
    Name = "${var.project_name}-ecs-log-group"
  })
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-ecs-task-execution-role"
  assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
      {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
          Service = "ecs-tasks.amazonaws.com"
          }
      }
      ]
  })
}

resource "aws_iam_role_policy" "ecs_allow_get_secret" {
  role   = aws_iam_role.ecs_task_execution_role.name
  name = "${var.project_name}-ecs-get-registry-secret"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowGetAndDescribeSecret"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = concat([var.registry_credentials_arn], values(var.ecs_container_secrets))
      },
      {
        Sid = "AllowKMSDecrypt"
        Action = [
          "kms:Decrypt"
        ]
        Effect = "Allow"
        Resource = [
          aws_kms_key.kms_key.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
    role       = aws_iam_role.ecs_task_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Cria security group para tasks ECS
resource "aws_security_group" "ecs_sg" {
    description = "Security group for ECS tasks in project ${var.project_name}"
    vpc_id      = var.vpc_id

    # Allow ECS tasks to reach VPC interface endpoints (HTTPS)
    ingress {
      description      = "Allow HTTPS to VPC endpoints (self)"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      self             = true
    }

    egress {
      description = "Allow all outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = merge(var.project_common_tags, {
        Name = "${var.project_name}-ecs-sg"
    })

    lifecycle {
      ignore_changes = [ingress]
    }
}

# Cria cluster ECS com Container Insights
resource "aws_ecs_cluster" "cluster" {
  name = "${var.project_name}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(var.project_common_tags, {
    Name = "${var.project_name}-ecs-cluster"
  })
}

# VPC Interface Endpoint para AWS Secrets Manager
resource "aws_vpc_endpoint" "secretsmanager_endpoint" {
  vpc_id             = var.vpc_id
  service_name       = "com.amazonaws.${data.aws_region.current.id}.secretsmanager"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [aws_security_group.ecs_sg.id]
  private_dns_enabled = true

  tags = merge(var.project_common_tags, {
    Name = "${var.project_name}-secretsmanager-endpoint"
  })
}

# VPC Interface Endpoint para AWS KMS (secrets encriptados)
resource "aws_vpc_endpoint" "kms_endpoint" {
  vpc_id             = var.vpc_id
  service_name       = "com.amazonaws.${data.aws_region.current.id}.kms"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [aws_security_group.ecs_sg.id]
  private_dns_enabled = true

  tags = merge(var.project_common_tags, {
    Name = "${var.project_name}-kms-endpoint"
  })
}
