data "aws_caller_identity" "current" {}

locals {
  // single topic configuration
  topic = var.topic

  subscription_items = length(coalesce(var.topic.subscriptions, [])) == 0 ? {} : {
    for idx, s in coalesce(var.topic.subscriptions, []) : format("%03d", idx) => s
  }
}

resource "aws_sns_topic" "this" {
  name                        = try(local.topic.name, null)
  display_name                = try(local.topic.display_name, null)
  fifo_topic                  = try(local.topic.fifo, null)
  content_based_deduplication = try(local.topic.content_based_deduplication, null)
  kms_master_key_id           = try(local.topic.kms_master_key_id, null)
  delivery_policy             = try(local.topic.delivery_policy, null)

  tags = merge(
    var.project_common_tags,
    try(local.topic.tags, {}),
    { Name = "sns-${try(local.topic.name, "topic")}" }
  )
}

resource "aws_sns_topic_subscription" "this" {
  for_each = local.subscription_items

  topic_arn            = aws_sns_topic.this.arn
  protocol             = lookup(each.value, "protocol", null)
  endpoint             = lookup(each.value, "endpoint", null)
  raw_message_delivery = lookup(each.value, "raw_message_delivery", false)
}

resource "aws_sns_topic_policy" "this" {
  count  = var.allow_s3_publish ? 1 : 0
  arn    = aws_sns_topic.this.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "SNS:Publish"
        Resource = aws_sns_topic.this.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = var.source_bucket_arn
          }
        }
      }
    ]
  })
}