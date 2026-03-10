#---------------------------------------------------------------------------------------------#
# Módulo para configurar um bucket S3 com opções de segurança e versionamento
#---------------------------------------------------------------------------------------------#


resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = merge(var.project_common_tags, {
    Name = var.bucket_name
  })
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = var.enable_encryption ? 1 : 0

  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_id != "" ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_id != "" ? var.kms_key_id : null
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = var.enable_lifecycle_rule ? 1 : 0

  bucket = aws_s3_bucket.this.id

  rule {
    id     = "auto-delete-objects"
    status = "Enabled"

    expiration {
      days = var.lifecycle_days
    }

    filter {}
  }
}

#---------------------------------------------------------------------------------------------#
# Notificações S3 para SNS/SQS
#---------------------------------------------------------------------------------------------#

resource "aws_s3_bucket_notification" "this" {
  count  = var.enable_notifications ? 1 : 0
  bucket = aws_s3_bucket.this.id

  dynamic "topic" {
    for_each = var.notification_topic_arn != "" ? [1] : []
    content {
      topic_arn = var.notification_topic_arn
      events    = var.notification_events
      filter_prefix = var.notification_filter_prefix
      filter_suffix = var.notification_filter_suffix
    }
  }

  dynamic "queue" {
    for_each = var.notification_queue_arn != "" ? [1] : []
    content {
      queue_arn = var.notification_queue_arn
      events    = var.notification_events
      filter_prefix = var.notification_filter_prefix
      filter_suffix = var.notification_filter_suffix
    }
  }
}

#---------------------------------------------------------------------------------------------#
# Política SNS para permitir que o S3 publique mensagens
#---------------------------------------------------------------------------------------------#

data "aws_iam_policy_document" "sns_topic_policy" {
  count = var.enable_notifications && var.notification_topic_arn != "" ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["SNS:Publish"]
    resources = [var.notification_topic_arn]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.this.arn]
    }
  }
}

resource "aws_sns_topic_policy" "s3_notification" {
  count  = var.enable_notifications && var.notification_topic_arn != "" ? 1 : 0
  arn    = var.notification_topic_arn
  policy = data.aws_iam_policy_document.sns_topic_policy[0].json
}

#---------------------------------------------------------------------------------------------#
# Política SQS para permitir que o S3 envie mensagens
# Nota: A política SQS deve ser aplicada no módulo SQS, não aqui
#---------------------------------------------------------------------------------------------#

data "aws_iam_policy_document" "sqs_queue_policy" {
  count = var.enable_notifications && var.notification_queue_arn != "" ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [var.notification_queue_arn]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.this.arn]
    }
  }
}



