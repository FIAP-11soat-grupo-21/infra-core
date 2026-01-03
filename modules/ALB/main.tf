#---------------------------------------------------------------------------------------------#
# Module para configurar um Application Load Balancer (ALB) interno
#---------------------------------------------------------------------------------------------#

data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.loadbalancer_name}-alb-sg"
  description = "SG para ALB (interno)"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from VPC (adjust as needed for VPC Link ENIs)"
    from_port   = var.app_port_init_range
    to_port     = var.app_port_end_range
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.project_common_tags, { Name = "${var.loadbalancer_name}-alb-sg" })
}

resource "aws_lb" "alb" {
  name               = "${var.loadbalancer_name}-alb"
  load_balancer_type = "application"
  internal           = var.is_internal
  subnets            = var.private_subnet_ids
  security_groups    = [aws_security_group.alb_sg.id]

  tags = merge(var.project_common_tags, { Name = "${var.loadbalancer_name}-alb" })
}

resource "aws_lb_target_group" "tg" {
  name        = "${var.loadbalancer_name}-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    matcher             = "200-399"
    interval            = 70
    healthy_threshold   = 10
    unhealthy_threshold = 10
    timeout             = 60
  }

  tags = merge(var.project_common_tags, { Name = "${var.loadbalancer_name}-tg" })
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  tags = merge(var.project_common_tags, { Name = "${var.loadbalancer_name}-listener" })
}
