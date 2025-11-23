// Lambda module: create a Lambda function that is always configured inside a VPC
// It optionally creates an API Gateway v2 integration + route when api_id and route_key are provided.

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.source_path
  output_path = "${path.module}/${var.lambda_name}.zip"
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.lambda_name}-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "vpc_access" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_policy" "extra" {
  name = "${var.lambda_name}-extra-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Effect = "Allow"
          Action = [
            "secretsmanager:GetSecretValue",
            "kms:Decrypt"
          ]
          Resource = var.secrets_arn == null ? [] : [var.secrets_arn]
        }
      ],
      var.allow_dynamodb_access ? [
        {
          Effect = "Allow"
          Action = [
            "dynamodb:PutItem",
            "dynamodb:GetItem",
            "dynamodb:Query",
            "dynamodb:Scan",
            "dynamodb:UpdateItem",
            "dynamodb:DeleteItem"
          ]
          Resource = var.dynamo_table_arn == null ? ["*"] : [var.dynamo_table_arn]
        }
      ] : []
    )
  })

  depends_on = [aws_iam_role.lambda_exec]
}

resource "aws_iam_role_policy_attachment" "extra_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.extra.arn
}

resource "aws_lambda_function" "this" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.lambda_name
  role             = aws_iam_role.lambda_exec.arn
  handler          = var.handler
  runtime          = var.runtime
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = var.environment
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  tags    = var.tags
  publish = true
}

resource "aws_lambda_permission" "apigw" {
  count         = local.create_api_integration ? 1 : 0
  statement_id  = "AllowAPIGatewayInvoke-${var.lambda_name}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.arn
  principal     = "apigateway.amazonaws.com"
  source_arn = local.create_api_integration ? "arn:aws:execute-api:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:${var.api_id}/*/*/*" : null
}

resource "aws_apigatewayv2_integration" "lambda" {
  count                  = local.create_api_integration ? 1 : 0
  api_id                 = var.api_id
  integration_type       = "AWS_PROXY"
  integration_uri        = "arn:aws:apigateway:${data.aws_region.current.id}:lambda:path/2015-03-31/functions/${aws_lambda_function.this.arn}/invocations"
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "lambda_route" {
  count    = local.create_api_integration ? 1 : 0
  api_id   = var.api_id
  route_key = var.route_key
  target    = "integrations/${aws_apigatewayv2_integration.lambda[0].id}"
  depends_on = [aws_apigatewayv2_integration.lambda]
}

// local to decide whether to create API integration/route
locals {
  create_api_integration = var.api_id != "" && var.route_key != ""
}

