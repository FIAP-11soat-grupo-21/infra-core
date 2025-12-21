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

