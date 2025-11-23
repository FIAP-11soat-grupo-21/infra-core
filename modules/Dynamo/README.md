# Dynamo module

This module creates a DynamoDB table with optional features and an IAM policy that can be attached to Lambdas or ECS task roles.

Features:
- Table with HASH and optional RANGE key
- Billing mode: PAY_PER_REQUEST (default) or PROVISIONED
- Optional Global Secondary Indexes (GSIs)
- Optional server-side encryption (SSE) with optional KMS key
- Optional TTL
- Optional streams
- Optional PITR (Point-in-time recovery)

Outputs:
- table_name
- table_arn
- table_stream_arn
- policy_arn (IAM policy that allows access to the table)

Example usage:

```hcl
module "dynamo" {
  source = "../Dynamo"
  name   = "app-table"
  hash_key = "pk"
  hash_key_type = "S"
  billing_mode = "PAY_PER_REQUEST"
}

# attach to lambda role
resource "aws_iam_role_policy_attachment" "lambda_dynamo_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = module.dynamo.policy_arn
}

# attach to ECS task role
resource "aws_iam_role_policy_attachment" "ecs_dynamo_attach" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = module.dynamo.policy_arn
}
```

