locals {
  sns_topic_keys     = [for idx in range(length(var.sns_topic_arns)) : format("%03d", idx)]
  sns_topic_arn_map  = length(var.sns_topic_arns) == 0 ? {} : zipmap(local.sns_topic_keys, var.sns_topic_arns)
}

resource "aws_sqs_queue" "main" {
  depends_on = [aws_sqs_queue.dead_letter]

  name                       = var.queue_name
  delay_seconds              = var.delay_seconds
  message_retention_seconds  = var.message_retention_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter.arn
    maxReceiveCount     = 4
  })

  tags = merge(var.project_common_tags, {
    Name = "sqs-${var.queue_name}"
  })
}

resource "aws_sqs_queue" "dead_letter" {
  name                      = "${var.queue_name}-dead-letter"
  message_retention_seconds = 1209600 # 14 days

  tags = merge(var.project_common_tags, {
    Name = "sqs-${var.queue_name}-dead-letter"
  })
}

resource "aws_sns_topic_subscription" "queue_bindings" {
  for_each = local.sns_topic_arn_map

  topic_arn = each.value
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.main.arn
}

resource "aws_sqs_queue_policy" "allow_sns" {
  count     = length(var.sns_topic_arns) == 0 ? 0 : 1
  queue_url = aws_sqs_queue.main.url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for topic_arn in values(local.sns_topic_arn_map) : {
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.main.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = topic_arn
          }
        }
      }
    ]
  })
}
