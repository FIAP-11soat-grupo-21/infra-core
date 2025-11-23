// DynamoDB module: create a table with optional GSIs, TTL, SSE and an IAM policy for access

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_dynamodb_table" "this" {
  name         = var.name
  billing_mode = var.billing_mode
  hash_key     = var.hash_key

  dynamic "attribute" {
    for_each = [var.hash_key]
    content {
      name = var.hash_key
      type = var.hash_key_type
    }
  }

  dynamic "attribute" {
    for_each = var.range_key != "" ? [var.range_key] : []
    content {
      name = var.range_key
      type = var.range_key_type
    }
  }

  range_key = var.range_key != "" ? var.range_key : null

  // throughput only set when using PROVISIONED
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name            = global_secondary_index.value.name
      hash_key        = global_secondary_index.value.hash_key
      range_key       = lookup(global_secondary_index.value, "range_key", null)
      projection_type = lookup(global_secondary_index.value, "projection_type", "ALL")

      // only set capacities when table is PROVISIONED
      read_capacity  = var.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "read_capacity", var.read_capacity) : null
      write_capacity = var.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "write_capacity", var.write_capacity) : null
    }
  }

  dynamic "server_side_encryption" {
    for_each = var.sse_enabled ? [1] : []
    content {
      enabled     = true
      kms_key_arn = var.kms_key_arn != "" ? var.kms_key_arn : null
    }
  }

  dynamic "ttl" {
    for_each = var.ttl_enabled ? [1] : []
    content {
      attribute_name = var.ttl_attribute
      enabled        = true
    }
  }

  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_view_type

  point_in_time_recovery {
    enabled = var.pitr
  }

  tags = merge(var.project_common_tags, var.tags, { Name = var.name })
}

resource "aws_iam_policy" "access_policy" {
  name   = "${var.name}-dynamodb-access"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = var.read_only ? [
          "dynamodb:GetItem",
          "dynamodb:BatchGetItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ] : [
          "dynamodb:*"
        ],
        Resource = [
          aws_dynamodb_table.this.arn,
          "${aws_dynamodb_table.this.arn}/index/*"
        ]
      },
      // allow DescribeTable for callers
      {
        Effect = "Allow",
        Action = ["dynamodb:DescribeTable"],
        Resource = aws_dynamodb_table.this.arn
      }
    ]
  })
}
