# Módulo ECS-Cluster

## Descrição

Cria um cluster ECS, roles, políticas e VPC endpoints necessários para executar tarefas ECS no VPC.

## Entradas (inputs)

| Nome | Tipo | Obrigatório | Descrição |
|------|------|:----------:|----------|
| project_common_tags | map(string) | Sim | Tags comuns do projeto |
| project_name | string | Sim | Nome do projeto |
| vpc_id | string | Sim | ID da VPC |
| private_subnet_ids | list(string) | Sim | Subnets privadas para tarefas |
| registry_credentials_arn | string | Não | ARN do Secret para credenciais do registry |
| ecs_container_secrets | map(string) | Não | Secrets a injetar nas tasks |

## Saídas (outputs)

| Nome | Descrição |
|------|-----------|
| cluster_id | ID do cluster ECS |
| cluster_arn | ARN do cluster |
| ecs_security_group_id | ID do Security Group para tasks |
| task_execution_role_arn | ARN do role de execução das tasks |
| cloudwatch_log_group | Nome do CloudWatch Log Group |

## Exemplo

```hcl
module "ecs_cluster" {
  source = "../ECS-Cluster"
  project_common_tags = local.project_common_tags
  project_name = var.project_name
  vpc_id = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  registry_credentials_arn = module.ghcr_secret.secret_arn
  ecs_container_secrets = { DB_PASSWORD = module.rds_postgres.db_secret_password_arn }
}
```
