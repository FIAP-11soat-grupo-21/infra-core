# Módulo API-Gateway-Routes

Este módulo configura rotas no API Gateway (HTTP API v2) integradas a um Application Load Balancer (ALB) via integração (integration proxy). O módulo cria uma rota principal (proxy), opcionalmente um autorizador JWT e uma rota restrita protegida por este autorizador.

Propósito
- Fazer a ponte entre a API Gateway e um ALB (integração `integrations/<alb_proxy_id>`).
- Permitir configuração opcional de um autorizador JWT e uma rota que exija autenticação.

Requisitos
- Terraform 0.12+.
- A API Gateway (HTTP API v2) deve já existir; passe o `api_id` como entrada.
- A integração do ALB (proxy) deve ser criada previamente (p.ex. pelo módulo que cria o ALB e o VPC Link) e seu id deve ser passado em `alb_proxy_id`.

Uso

Exemplo básico (rota proxy pública):

```hcl
module "api_routes" {
  source        = "../../modules/API-Gateway-Routes"

  api_id        = module.api_gateway.api_id
  gwapi_route_key = "ANY /{proxy+}"
  alb_proxy_id  = module.api_gateway.alb_proxy_id
}
```

Exemplo com JWT authorizer e rota restrita:

```hcl
module "api_routes_secure" {
  source               = "../../modules/API-Gateway-Routes"

  api_id               = module.api_gateway.api_id
  gwapi_route_key      = "ANY /{proxy+}"
  alb_proxy_id         = module.api_gateway.alb_proxy_id

  jwt_authorizer_enabled = true
  jwt_authorizer_name    = "my-jwt-auth"
  jwt_issuer             = "https://accounts.example.com/"
  jwt_audiences          = ["api://default"]

  # Rota que exigirá JWT
  restricted_route_key  = "GET /secure"
}
```

Inputs (variáveis)

| Nome | Tipo | Default | Obrigatório | Descrição |
|------|------|---------|------------:|-----------|
| `api_id` | string | n/a | sim | ID da API Gateway (HTTP API v2) onde as rotas serão criadas. |
| `gwapi_route_key` | string | n/a | sim | Route key do API Gateway (ex.: `ANY /{proxy+}`, `GET /health`). |
| `jwt_authorizer_enabled` | bool | `false` | não | Habilita criação de autorizador JWT (se true cria o recurso `aws_apigatewayv2_authorizer`). |
| `jwt_authorizer_name` | string | `"jwt-authorizer"` | não | Nome do autorizador JWT criado. |
| `jwt_issuer` | string | `null` | não* | URL do issuer (ex.: `https://accounts.example.com/`). Requerido se `jwt_authorizer_enabled = true`. |
| `jwt_audiences` | list(string) | `[]` | não* | Lista de audiences esperadas pelo autorizador JWT. Recomendado configurar quando `jwt_authorizer_enabled = true`. |
| `jwt_identity_sources` | list(string) | `["$request.header.Authorization"]` | não | Fonte(s) de identidade para o autorizador (p.ex. header Authorization). |
| `restricted_route_key` | string | `null` | não | Route key opcional que será protegida pelo autorizador JWT. Ex.: `GET /secure`. Se `null` não é criada rota restrita. |
| `alb_proxy_id` | string | n/a | sim | ID da integração (proxy) do ALB no API Gateway. Normalmente obtido do módulo que cria a integração ALB<->API Gateway. |

Notas sobre inputs
- Se `jwt_authorizer_enabled = true`, forneça `jwt_issuer` e `jwt_audiences` adequados; do contrário a configuração do autorizador ficará incompleta.
- `gwapi_route_key` determina a rota criada. Para criar rotas adicionais, instancie o módulo múltiplas vezes com `count`/`for_each` ou estenda o módulo.
- `alb_proxy_id` geralmente vem de um recurso `aws_apigatewayv2_integration` criado previamente.

Outputs

Este módulo não fornece outputs explícitos. Ele cria os recursos:
- `aws_apigatewayv2_route.proxy`
- `aws_apigatewayv2_deployment.api_deployment`
- `aws_apigatewayv2_authorizer.jwt` (opcional)
- `aws_apigatewayv2_route.restricted` (opcional)

Se você precisar de outputs (ex.: ID da rota, ID do authorizer), adicione um `output` no módulo ou abra uma issue/pull request para que eu adicione them.

Boas práticas
- Garanta que a API (`api_id`) exista antes de aplicar o módulo.
- Use `count` ou `for_each` no módulo chamador para criar múltiplas rotas de forma declarativa.
- Crie uma integração reutilizável (`aws_apigatewayv2_integration`) que retorne o `integration_id` (`alb_proxy_id`) e compartilhe entre instâncias do módulo.
- Para ambientes produtivos configure `stage` e deployments fora deste módulo, ou adapte o módulo para suportar lifecycle/auto-deploy conforme sua convenção.
- Sempre execute `terraform validate` e `terraform plan` antes de aplicar.

Comandos úteis

```bash
terraform init
terraform validate
terraform plan -var-file=env/dev.tfvars
```

Sugestões de melhoria
- Adicionar outputs opcionais (route IDs, authorizer ID).
- Permitir criar múltiplas rotas a partir de uma lista (refatoração para `for_each`).

Licença
- Confira a licença no repositório raiz.

Contato
- Atualize o README do repositório raiz com convenções e contatos do time para dúvidas sobre módulos.

