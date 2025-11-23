# Módulo API-Gateway-Routes

## Descrição

Cria rotas e integrações para a API Gateway (HTTP API v2). Este módulo assume que a API e o VPC Link já foram criados pelo módulo `API-Gateway`.

## Entradas (inputs)

| Nome | Tipo | Obrigatório | Descrição |
|------|------|:----------:|----------|
| api_id | string | Sim | ID da API Gateway onde as rotas serão criadas |
| vpc_link_id | string | Sim | ID do VPC Link para integração com ALB |
| alb_listener_arn | string | Sim | ARN do listener do ALB (usado para integração) |
| gwapi_route_key | string | Sim | Rota a ser criada (ex: "ANY /{proxy+}") |
| gwapi_auto_deploy | bool | Não | Habilita auto-deploy |
| stage_name | string | Não | Nome do estágio |
| project_common_tags | map(string) | Não | Tags comuns do projeto |
| api_gw_logs_arn | string | Não | ARN do log group da API |

## Saídas (outputs)

| Nome | Descrição |
|------|-----------|
| (nenhuma) | As saídas importantes ficam no módulo `API-Gateway` principal |

## Exemplo

```hcl
module "api_gateway_routes" {
  source = "../API-Gateway-Routes"
  api_id = module.api_gateway.api_id
  vpc_link_id = module.api_gateway.vpc_link_id
  alb_listener_arn = module.alb.listener_arn
  gwapi_route_key = var.gwapi_route_key
  gwapi_auto_deploy = var.gwapi_auto_deploy
  stage_name = var.gwapi_stage_name
}
```

## Notas
- O módulo cria rotas do tipo HTTP->ALB ou HTTP->Lambda dependendo das entradas.
