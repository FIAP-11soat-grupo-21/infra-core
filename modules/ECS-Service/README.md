# Módulo ECS-Service

Este módulo cria um ECS Service e Task Definition para executar containers no cluster ECS, com integração opcional a um ALB Target Group.

Objetivos
- Criar Task Definition, ECS Service e integrar com ALB Target Group quando fornecido.

Requisitos
- Terraform 0.12+ e provider AWS configurado.
- Um ECS Cluster existente (passe `cluster_id`), subnets privadas e security group.

Uso

```hcl
module "ecs_service" {
  source = "../../modules/ECS-Service"

  cluster_id                    = module.ecs_cluster.cluster_id
  ecs_security_group_id         = module.ecs_cluster.ecs_security_group_id
  task_execution_role_arn       = module.ecs_cluster.task_execution_role_arn
  cloudwatch_log_group          = module.ecs_cluster.cloudwatch_log_group
  private_subnet_ids            = module.vpc.private_subnet_ids

  ecs_container_name            = "app"
  ecs_container_image           = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest"
  ecs_container_port            = 8080
  ecs_desired_count             = 2
  ecs_service_name              = "my-app-service"

  alb_target_group_arn          = module.alb.target_group_arn
  alb_security_group_id         = module.alb.alb_security_group_id
}
```

Inputs (variáveis)

| Nome | Tipo | Default | Descrição |
|------|------|---------|-----------|
| `project_common_tags` | map(string) | `{}` | Tags aplicadas aos recursos. |
| `cluster_id` | string | n/a | ID do ECS Cluster. |
| `ecs_security_group_id` | string | n/a | ID do security group para as tasks. |
| `task_execution_role_arn` | string | n/a | ARN da role usada para executar tasks. |
| `task_role_arn` | string | `""` | ARN opcional da task role (se não fornecida, uma role será criada pelo módulo). |
| `cloudwatch_log_group` | string | n/a | Nome do CloudWatch log group. |
| `private_subnet_ids` | list(string) | n/a | Subnets privadas para tasks. |
| `registry_credentials_arn` | string | `""` | ARN do Secret com credenciais do registry. |
| `ecs_container_name` | string | n/a | Nome do container na task definition. |
| `ecs_container_image` | string | n/a | Imagem do container (ECR/Registry). |
| `ecs_container_port` | number | n/a | Porta exposta pelo container. |
| `ecs_container_environment_variables` | map(string) | `{}` | Variáveis de ambiente para o container. |
| `ecs_container_secrets` | map(string) | `{}` | Mapeamento de secrets do Secrets Manager para injetar no container. |
| `ecs_desired_count` | number | `1` | Desired count do serviço. |
| `ecs_network_mode` | string | `awsvpc` | Network mode para a task. |
| `ecs_task_cpu` | string | `256` | CPU units para a task. |
| `ecs_task_memory` | string | `512` | Memória para a task. |
| `ecs_service_name` | string | n/a | Nome do ECS Service. |
| `alb_target_group_arn` | string | `""` | ARN do Target Group do ALB para integrar o serviço (opcional). |
| `alb_security_group_id` | string | `""` | SG do ALB (opcional). |
| `task_role_policy_arns` | list(string) | `[]` | ARNs de policies para anexar à task role. |

Outputs

| Nome | Tipo | Descrição |
|------|------|-----------|
| `service_id` | string | ID do ECS Service criado. |
| `task_definition_arn` | string | ARN da Task Definition criada. |
| `task_role_arn` | string/null | ARN da task role usada (ou `null` se não aplicável). |

Boas práticas
- Use health checks e configure o ALB Target Group health check para garantir deploys seguros.
- Gerencie imagens em ECR e utilize rotas de cache e roles mínimos para execução.

Comandos úteis

```bash
terraform init
terraform validate
terraform plan -var-file=env/dev.tfvars
```

