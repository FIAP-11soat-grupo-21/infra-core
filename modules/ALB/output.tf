output "alb_arn" {
  description = "ARN do Application Load Balancer (ALB)."
  value       = aws_lb.alb.arn
}

output "alb_dns_name" {
  description = "Nome DNS do ALB (ex.: example-alb-123456.us-east-1.elb.amazonaws.com)."
  value       = aws_lb.alb.dns_name
}

output "alb_security_group_id" {
  description = "ID do Security Group associado ao ALB."
  value       = aws_security_group.alb_sg.id
}

output "target_group_arn" {
  description = "ARN do Target Group utilizado pelo ALB."
  value       = aws_lb_target_group.tg.arn
}

output "listener_arn" {
  description = "ARN do Listener do ALB."
  value       = aws_lb_listener.listener.arn
}
