#---------------------------------------------------------------------------------------------#
# Módulo para configurar o serviço ECS com definição de tarefa e recursos associados
#---------------------------------------------------------------------------------------------#

data "aws_region" "current" {}

data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  count = var.task_role_arn == "" ? 1 : 0

  name               = "${var.ecs_service_name}-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json

  tags = merge(var.project_common_tags, {
    Name = "${var.ecs_service_name}-task-role"
  })
}

locals {
  ecs_task_role_name = var.task_role_arn != "" ? split("/", var.task_role_arn)[1] : (length(aws_iam_role.ecs_task_role) > 0 ? aws_iam_role.ecs_task_role[0].name : null)
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_attachments" {
  count      = local.ecs_task_role_name != null ? length(var.task_role_policy_arns) : 0
  role       = local.ecs_task_role_name
  policy_arn = var.task_role_policy_arns[count.index]
}

locals {
  ecs_cluster_name = length(split("/", var.cluster_id)) > 1 ? element(split("/", var.cluster_id), length(split("/", var.cluster_id)) - 1) : var.cluster_id

  ecs_environment = [for key, value in var.ecs_container_environment_variables : {
    name  = key
    value = value
  }]

  ecs_secrets = [for key, value in var.ecs_container_secrets : {
    name      = key
    valueFrom = value
  }]

  ecs_base_container = {
    name      = var.ecs_container_name
    image     = var.ecs_container_image
    essential = true
    portMappings = [
      {
        containerPort = var.ecs_container_port
        hostPort      = var.ecs_container_port
        protocol      = "tcp"
      }
    ]
    environment = local.ecs_environment
    secrets     = local.ecs_secrets
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = var.cloudwatch_log_group
        awslogs-region        = data.aws_region.current.id
        awslogs-stream-prefix = "ecs"
      }
    }
    repositoryCredentials = null
  }

  container_def_map = var.registry_credentials_arn != "" ? merge(local.ecs_base_container, {
    repositoryCredentials = {
      credentialsParameter = var.registry_credentials_arn
    }
  }) : local.ecs_base_container
}

resource "aws_ecs_task_definition" "tasks" {
  family                   = "${var.ecs_service_name}-service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = var.ecs_network_mode
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn != "" ? var.task_role_arn : (length(aws_iam_role.ecs_task_role) > 0 ? aws_iam_role.ecs_task_role[0].arn : null)

  container_definitions = jsonencode([
    local.container_def_map
  ])

  tags = merge(var.project_common_tags, {
    Name = "${var.ecs_service_name}-ecs-task-definition"
  })
}

resource "aws_ecs_service" "service" {
  name            = var.ecs_service_name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.tasks.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  dynamic "load_balancer" {
    for_each = var.alb_target_group_arn != "" ? [var.alb_target_group_arn] : []
    content {
      target_group_arn = load_balancer.value
      container_name   = trimspace(var.ecs_container_name)
      container_port   = var.ecs_container_port
    }
  }

  tags = merge(var.project_common_tags, {
    Name = "${trimspace(var.ecs_service_name)}-ecs-service"
  })

  lifecycle {
    ignore_changes = var.enable_ecs_autoscaling ? [desired_count] : []
  }
}

resource "aws_appautoscaling_target" "ecs_service" {
  count = var.enable_ecs_autoscaling ? 1 : 0

  max_capacity       = var.ecs_autoscaling_max_capacity
  min_capacity       = var.ecs_autoscaling_min_capacity
  resource_id        = "service/${local.ecs_cluster_name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  lifecycle {
    precondition {
      condition     = var.ecs_autoscaling_max_capacity >= var.ecs_autoscaling_min_capacity
      error_message = "ecs_autoscaling_max_capacity must be greater than or equal to ecs_autoscaling_min_capacity."
    }
  }
}

resource "aws_appautoscaling_policy" "ecs_cpu_target" {
  count = var.enable_ecs_autoscaling ? 1 : 0

  name               = "${var.ecs_service_name}-cpu-target-tracking"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_service[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.ecs_autoscaling_cpu_target
    scale_in_cooldown  = var.ecs_autoscaling_scale_in_cooldown
    scale_out_cooldown = var.ecs_autoscaling_scale_out_cooldown
  }
}

resource "aws_appautoscaling_policy" "ecs_memory_target" {
  count = var.enable_ecs_autoscaling ? 1 : 0

  name               = "${var.ecs_service_name}-memory-target-tracking"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_service[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = var.ecs_autoscaling_memory_target
    scale_in_cooldown  = var.ecs_autoscaling_scale_in_cooldown
    scale_out_cooldown = var.ecs_autoscaling_scale_out_cooldown
  }
}

resource "aws_security_group_rule" "allow_alb_to_ecs" {
  type                     = "ingress"
  from_port                = var.ecs_container_port
  to_port                  = var.ecs_container_port
  protocol                 = "tcp"
  security_group_id        = var.ecs_security_group_id
  source_security_group_id = var.alb_security_group_id
  description              = "Allow ALB to reach ECS tasks"
}
