# Módulo ALB (Application Load Balancer)

## Descrição

Este módulo cria um Application Load Balancer (ALB), target group e listener para expor serviços (ex.: ECS) dentro de uma VPC.

## Entradas (inputs)

| Nome                  | Tipo          | Obrigatório | Descrição                                                       |
|-----------------------|---------------|:----------:|---------------------------------------------------------------|
| project_common_tags   | map(string)   | Sim        | Tags comuns do projeto (serão mescladas)                      |
| project_name          | string        | Sim        | Nome do projeto (usado em nomes)                              |
| vpc_id                | string        | Sim        | ID da VPC onde o ALB será criado                              |
| private_subnet_ids    | list(string)  | Sim        | IDs das subnets privadas onde o ALB ficará                    |
| app_port              | number        | Sim        | Porta do aplicativo (target)                                  |
| loadbalancer_name     | string        | Não        | Nome do ALB (opcional)                                       |
| vpc_cidr_blocks       | list(string)  | Não        | CIDRs permitidos nas regras do ALB                            |
| health_check_path     | string        | Não        | Caminho usado para health check (ex: /health)                |

## Saídas (outputs)

| Nome                  | Descrição                                                       |
|-----------------------|---------------------------------------------------------------|
| alb_arn               | ARN do ALB                                                    |
| alb_dns_name          | Nome DNS público do ALB                                      |
| alb_security_group_id | ID do Security Group do ALB                                  |
| target_group_arn      | ARN do target group                                          |
| listener_arn          | ARN do listener                                              |

## Exemplo de uso

```hcl
module "alb" {
  source = "../ALB"
  project_common_tags = local.project_common_tags
  project_name = var.project_name
  vpc_id = module.vcp.vpc_id
  private_subnet_ids = module.vcp.private_subnets
  app_port = var.ecs_container_port
  loadbalancer_name = var.lb_name
  vpc_cidr_blocks = [var.vpc_cidr]
  health_check_path = "/health"
}
```

## Notas

- O módulo espera que a VPC e subnets já existam (ex.: módulo `VPC`).
- Recomendado revisar as regras de segurança conforme seu cenário (ex.: permitir acesso apenas de ALBs/CloudFront ou CIDRs confiáveis).
