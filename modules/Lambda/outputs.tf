output "lambda_arn" {
  value = aws_lambda_function.this.arn
}
output "vpc_subnet_ids" {
  value = var.subnet_ids
}
