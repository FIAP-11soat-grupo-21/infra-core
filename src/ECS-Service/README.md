# Módulo ECS-Service

## Descrição

Cria uma task definition e um serviço ECS que roda containers; integra-se com ALB para expor o serviço.

## Entradas (inputs)

| Nome | Tipo | Obrigatório | Descrição |
|------|------|:----------:|----------|
| project_common_tags | map(string) | Sim | Tags comuns do projeto |
| project_name | string | Sim | Nome do projeto |
| cluster_id | string | Sim | ID do cluster ECS |
| private_subnet_ids | list(string) | Sim | Subnets privadas onde as tasks serão executadas |
| registry_credentials_arn | string | Sim | ARN do Secret com credenciais do registry |
| ecs_container_name | string | Sim | Nome do container na task definition |
| ecs_container_image | string | Sim | Imagem do container (ex: repo/image:tag) |
| ecs_container_port | number | Sim | Porta exposta pelo container |
| ecs_container_environment_variables | map(string) | Não | Variáveis de ambiente para o container |
| ecs_container_secrets | map(string) | Não | Segredos a injetar no container |
| ecs_desired_count | number | Não | Número desejado de instâncias do serviço |
| ecs_task_cpu | string | Não | CPU da task (unit) |
| ecs_task_memory | string | Não | Memória da task (MiB) |
| ecs_service_name | string | Não | Nome do serviço ECS |
| alb_target_group_arn | string | Não | ARN do target group do ALB para registrar as tasks |
| alb_security_group_id | string | Não | ID do SG do ALB (para configurar regras) |

## Saídas (outputs)

| Nome | Descrição |
|------|-----------|
| service_arn | ARN do serviço ECS (se o módulo criar) |
| task_definition_arn | ARN da task definition (se o módulo criar) |

## Exemplo de uso

```hcl
module "ecs_api" {
  source = "../ECS-Service"
  project_common_tags = local.project_common_tags
  project_name = var.project_name
  cluster_id = module.ecs_cluster.cluster_id
  private_subnet_ids = module.vcp.private_subnets
  registry_credentials_arn = module.ghcr_secret.secret_arn
  ecs_container_name = var.ecs_container_name
  ecs_container_image = var.ecs_container_image
  ecs_container_port = var.ecs_container_port
  ecs_container_environment_variables = { DB_HOST = module.rds_postgres.db_connection }
  ecs_container_secrets = { DB_PASSWORD = module.rds_postgres.db_secret_password_arn }
  alb_target_group_arn = module.alb.target_group_arn
}
```

## Notas

- Verifique a configuração de security groups entre ALB e tasks para permitir tráfego na porta correta.
- Se desejar auto-scaling ou integração com Service Discovery, expanda este módulo conforme necessário.
