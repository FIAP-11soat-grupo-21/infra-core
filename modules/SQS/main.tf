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
