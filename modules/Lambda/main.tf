data "aws_region" "current" {}

data "aws_apigatewayv2_api" "this" {
  api_id = var.api_id
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

data "aws_iam_policy_document" "role_permissions" {
  for_each = var.role_permissions

  statement {
    sid    = each.key
    effect = each.value.effect

    actions   = each.value.actions
    resources = each.value.resources
  }
}

resource "aws_iam_role_policy" "inline_permissions" {
  for_each = var.role_permissions

  name = "${var.lambda_name}-permissions-${each.key}"
  role = aws_iam_role.lambda_exec.name
  policy = data.aws_iam_policy_document.role_permissions[each.key].json
}

data "archive_file" "layer_zip" {
  count       = var.layer_enabled ? 1 : 0
  type        = "zip"
  source_dir  = var.layer_source_path
  output_path = "${path.module}/${var.layer_name}.zip"
}

resource "aws_lambda_layer_version" "this" {
  count                     = var.layer_enabled ? 1 : 0
  filename                  = data.archive_file.layer_zip[0].output_path
  layer_name                = var.layer_name
  compatible_runtimes       = var.layer_compatible_runtimes
  compatible_architectures  = var.layer_compatible_architectures
  description               = var.layer_description
  license_info              = var.layer_license_info
}

resource "aws_lambda_function" "this" {
  # Usar código armazenado no S3 (ao invés de arquivo zip local)
  function_name    = var.lambda_name
  role             = aws_iam_role.lambda_exec.arn
  handler          = var.handler
  runtime          = var.runtime
  timeout         = var.timeout
  memory_size     = var.memory_size

  s3_bucket = var.s3_bucket
  s3_key    = var.s3_key
  # Opcional: s3_object_version = var.s3_object_version

  environment {
    variables = var.environment
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  layers = var.layer_enabled ? [aws_lambda_layer_version.this[0].arn] : []

  tags    = var.tags
  publish = true
}

resource "aws_security_group" "lambda_sg" {
  name        = "${var.lambda_name}-sg"
  description = "Security group for ${var.lambda_name} Lambda"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke-${var.lambda_name != "" ? var.lambda_name : substr(md5(aws_lambda_function.this.function_name),0,8)}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${data.aws_apigatewayv2_api.this.arn}/*/*"
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = var.api_id
  integration_type       = "AWS_PROXY"
  integration_uri        = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.this.arn}/invocations"
  integration_method     = "POST"
  payload_format_version = var.payload_format_version
}
