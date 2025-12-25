# Módulo ECS-Cluster

Este módulo cria um cluster ECS com recursos auxiliares (security group, KMS key, CloudWatch log group, roles e VPC endpoints necessários para execução de tasks).

Objetivos
- Provisionar um cluster ECS pronto para executar tasks Fargate ou EC2, com roles, logs e endpoints necessários.

Requisitos
- Terraform 0.12+ e provider AWS configurado.

Uso

```hcl
module "ecs_cluster" {
  source = "../../modules/ECS-Cluster"

  project_name            = "myproject"
  vpc_id                  = module.vpc.vpc_id
  private_subnet_ids      = module.vpc.private_subnet_ids
  registry_credentials_arn= aws_secretsmanager_secret.credentials.arn
  ecs_container_secrets   = { DB_PASSWORD = aws_secretsmanager_secret.db.secret_arn }
  project_common_tags     = { Environment = var.environment }
}
```

Inputs (variáveis)

| Nome | Tipo | Default | Descrição |
|------|------|---------|-----------|
| `project_name` | string | n/a | Nome do projeto/cluster. |
| `project_common_tags` | map(string) | `{}` | Tags aplicadas aos recursos. |
| `vpc_id` | string | n/a | ID da VPC onde o cluster será criado. |
| `private_subnet_ids` | list(string) | n/a | Lista de subnets privadas para tasks e endpoints. |
| `registry_credentials_arn` | string | n/a | ARN do secret com credenciais do registry (para pull de imagens privadas). |
| `ecs_container_secrets` | map(string) | `{}` | Mapeamento de variáveis de ambiente para secrets do Secrets Manager. |
| `project_description` | string | `""` | Descrição opcional do projeto. |

Outputs

| Nome | Tipo | Descrição |
|------|------|-----------|
| `cluster_id` | string | ID do ECS Cluster. |
| `cluster_arn` | string | ARN do ECS Cluster. |
| `ecs_security_group_id` | string | ID do Security Group usado pelo ECS. |
| `kms_key_arn` | string | ARN da KMS Key criada para o cluster. |
| `cloudwatch_log_group` | string | Nome do CloudWatch Log Group criado. |
| `task_execution_role_arn` | string | ARN da role usada para execução de tasks. |
| `secretsmanager_vpc_endpoint_id` | string | ID do endpoint VPC para Secrets Manager. |
| `kms_vpc_endpoint_id` | string | ID do endpoint VPC para KMS. |

Boas práticas
- Armazene segredos no Secrets Manager e referencie via `ecs_container_secrets`.
- Garanta IAM mínimo para as roles criadas e revise permissões conforme políticas internas.

Comandos úteis

```bash
terraform init
terraform validate
terraform plan -var-file=env/dev.tfvars
```

