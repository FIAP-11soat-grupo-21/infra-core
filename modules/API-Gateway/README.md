# Módulo API-Gateway (HTTP API v2)

## Descrição

Cria uma API Gateway HTTP (apigatewayv2) com VPC Link e recursos necessários para integrar ALB.

## Entradas (inputs)

| Nome | Tipo | Obrigatório | Descrição |
|------|------|:----------:|----------|
| project_common_tags | map(string) | Sim | Tags comuns do projeto |
| project_name | string | Sim | Nome do projeto |
| private_subnet_ids | list(string) | Sim | Subnets privadas para o VPC Link |
| alb_security_group_id | string | Sim | Security Group do ALB para integração |
| api_name | string | Não | Nome da API (opcional) |

## Saídas (outputs)

| Nome | Descrição |
|------|-----------|
| api_id | ID da API Gateway v2 |
| api_endpoint | Endpoint público da API |
| vpc_link_id | ID do VPC Link criado |
| api_gw_logs_arn | ARN do CloudWatch Log Group da API |

## Exemplo

```hcl
module "api_gateway" {
  source = "../API-Gateway"
  project_common_tags = local.project_common_tags
  project_name = var.project_name
  private_subnet_ids = module.vcp.private_subnets
  alb_security_group_id = module.alb.alb_security_group_id
  api_name = var.gwapi_name
}
```

## Notas
- Para criar rotas/integrations, use o módulo `API-Gateway-Routes`.
