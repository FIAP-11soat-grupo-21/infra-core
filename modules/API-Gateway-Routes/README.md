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
| jwt_authorizer_enabled | bool | Não | Habilita a criação de um Authorizer JWT |
| jwt_authorizer_name | string | Não | Nome do authorizer JWT |
| jwt_issuer | string | Cond. | Issuer do JWT (ex: https://cognito-idp.{region}.amazonaws.com/{userPoolId} ou provedor OIDC) |
| jwt_audiences | list(string) | Cond. | Lista de audiences válidas |
| jwt_identity_sources | list(string) | Não | Fontes de identidade (padrão: "$request.header.Authorization") |
| restricted_route_key | string | Não | Rota opcional que exigirá JWT (ex: "GET /restricted") |

Notas:
- `jwt_issuer` e `jwt_audiences` são obrigatórios quando `jwt_authorizer_enabled = true`.

## Saídas (outputs)

| Nome | Descrição |
|------|-----------|
| (nenhuma) | As saídas importantes ficam no módulo `API-Gateway` principal |

## Exemplo

```hcl
module "api_gateway_routes" {
  source            = "../API-Gateway-Routes"
  api_id            = module.api_gateway.api_id
  vpc_link_id       = module.api_gateway.vpc_link_id
  alb_listener_arn  = module.alb.listener_arn
  gwapi_route_key   = "ANY /{proxy+}"
  gwapi_auto_deploy = true
  stage_name        = "$default"

  # Configuração opcional de rota protegida por JWT
  jwt_authorizer_enabled = true
  jwt_authorizer_name    = "jwt-auth"
  jwt_issuer             = var.jwt_issuer
  jwt_audiences          = ["my-api"]
  jwt_identity_sources   = ["$request.header.Authorization"]

  # Rota que exigirá JWT
  restricted_route_key = "GET /restricted"
}
```

## Notas
- O módulo cria rotas do tipo HTTP->ALB. Quando habilitado, adiciona um authorizer JWT e uma rota adicional protegida por ele.
