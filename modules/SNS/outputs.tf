output "topic_arn" {
  description = "The ARN of the SNS topic."
  value       = aws_sns_topic.this.arn
}

output "topic_name" {
  description = "The name of the SNS topic."
  value       = aws_sns_topic.this.name
}

output "subscriptions" {
  description = "Map of subscription ids to subscription resources (objects)."
  value       = { for k, s in aws_sns_topic_subscription.this : k => s }
}
