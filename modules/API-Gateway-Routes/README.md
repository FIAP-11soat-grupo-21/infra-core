# Módulo API-Gateway-Routes

Este módulo cria rotas no API Gateway (HTTP API v2) integradas a um Application Load Balancer (ALB) via integração (integration proxy). As rotas são geradas dinamicamente a partir do mapa `endpoints` passado como entrada.

## Propósito
- Criar rotas no API Gateway a partir de um mapa de endpoints.
- Integrar cada rota ao ALB usando o `alb_proxy_id` (integração pré-existente).
- Marcar rotas como protegidas (`restricted`) para adicionar `authorization_type = "JWT"` e associar um `authorizer_id` quando fornecido por rota.

## Requisitos
- Terraform compatível com a sintaxe usada no módulo.
- A API Gateway (HTTP API v2) já deve existir; passe o `api_id` como entrada.
- A integração do ALB (proxy) deve ser criada previamente (p.ex. pelo módulo que cria o ALB e o VPC Link) e seu id deve ser passado em `alb_proxy_id`.

## Comportamento atual
- O módulo não cria um autorizador JWT por conta própria. Em vez disso, quando uma entrada do mapa `endpoints` tem `restricted = true` o recurso de rota será criado com `authorization_type = "JWT"` e o campo `authorizer_id` será definido a partir de `endpoints[<key>].auth_integration_name` (se fornecido).
- Se `auth_integration_name` não for fornecido para uma rota marcada como `restricted`, o módulo configura `authorization_type` como `JWT` e define o `authorizer_id` como `null` — neste caso a associação ficará incompleta e a rota pode ficar inválida no API Gateway até que um autorizador válido seja associado.
- O recurso `aws_apigatewayv2_deployment` é criado e forçado a depender das rotas dinâmicas para garantir que as mudanças em rotas provoquem um novo deployment.

> Nota: existe a variável `jwt_authorizer_name` no módulo por compatibilidade, porém o módulo como está hoje não cria o recurso `aws_apigatewayv2_authorizer`. Se deseja que o módulo também crie o autorizador, é necessário adicionar os recursos e variáveis correspondentes no `main.tf`.

## Uso

O módulo espera um mapa `endpoints` (chave => object) com o esquema abaixo:

- route_key: string — (ex.: `ANY /{proxy+}`, `GET /health`)
- target: optional(string) — valor usado internamente no módulo para identificar um target/back-end (opcional)
- restricted: optional(bool) — se true, a rota será criada com `authorization_type = "JWT"`
- auth_integration_name: optional(string) — valor que será usado como `authorizer_id` na rota (deve ser o ID do autorizador já existente no API Gateway)

Exemplo:

```hcl
module "api_routes" {
  source = "../../modules/API-Gateway-Routes"

  api_id      = module.api_gateway.api_id
  alb_proxy_id = module.api_gateway.alb_proxy_id

  endpoints = {
    public = {
      route_key = "ANY /{proxy+}"
      target    = "app-proxy"
    }

    health = {
      route_key = "GET /health"
      target    = "health"
    }

    secure = {
      route_key = "GET /secure"
      restricted = true
      auth_integration_id = "<existing-authorizer-id>"  # ID do autorizador JWT já existente
      target    = "secure-app"
    }
  }

  # jwt_authorizer_name está presente como variável de compatibilidade, mas
  # o módulo não cria o autorizador automaticamente no estado atual.
  auth_integration_id = "my-jwt-auth"
}
```

Exemplo mínimo:

```hcl
module "api_routes_single" {
  source = "../../modules/API-Gateway-Routes"

  api_id      = module.api_gateway.api_id
  alb_proxy_id = module.api_gateway.alb_proxy_id

  endpoints = {
    default = {
      route_key = "ANY /{proxy+}"
    }
  }
}
```

## Inputs (variáveis)

| Nome | Tipo | Default | Obrigatório | Descrição |
|------|------|---------|------------:|-----------|
| `api_id` | string | n/a | sim | ID da API Gateway (HTTP API v2) onde as rotas serão criadas. |
| `endpoints` | map(object) | n/a | sim | Mapa de endpoints: chave => object({ route_key = string, target = optional(string), restricted = optional(bool), auth_integration_name = optional(string) }). O módulo cria uma rota por entrada do mapa. |
| `jwt_authorizer_name` | string | `"jwt-authorizer"` | não | Variável presente para compatibilidade; atualmente não é utilizada pelo módulo para criar autorizadores. |
| `alb_proxy_id` | string | n/a | sim | ID da integração (proxy) do ALB no API Gateway. Normalmente obtido do módulo que cria a integração ALB<->API Gateway. |

### Observações sobre inputs
- `auth_integration_name` deve conter o ID do autorizador JWT já existente no API Gateway se você quiser associar esse autorizador a uma rota marcada como `restricted`.
- Se você precisa que o módulo crie o autorizador JWT automaticamente, adicione os recursos `aws_apigatewayv2_authorizer` no `main.tf` e as variáveis necessárias para `issuer` e `audiences`.

## Outputs
O módulo expõe atualmente os seguintes outputs (conforme `outputs.tf`):

- `api_id` — ID da API Gateway recebido como entrada.
- `api_name` — Nome da API recuperado via data source.
- `api_endpoint` — Endpoint público (se aplicável) da API Gateway v2.
- `deployment_id` — ID da implantação (`aws_apigatewayv2_deployment`) criada pelo módulo.
- `authorizer_id` — Tenta recuperar `aws_apigatewayv2_authorizer.jwt[0].id` (retorna string vazia se não existir). Como o módulo não cria um autorizador por padrão, este output normalmente ficará vazio a menos que um autorizador com o nome/índice esperado exista no plano.

Observação: o output `routes` (map de ids das rotas) não está implementado atualmente — pode ser útil expor esse mapa para consumo por módulos que dependam diretamente dos ids das rotas.

## Boas práticas e sugestões
- Garanta que a API (`api_id`) exista antes de aplicar o módulo.
- Crie e gerencie o autorizador JWT separadamente (ou estenda o módulo) se precisar de um authorizer centralizado.
- Considere adicionar validações (`validation` blocks) em `variables.tf` para impor que, quando `restricted = true` seja fornecido `auth_integration_name` ou que uma configuração de autorizador global exista.
- Expor um output `routes` com um mapa `{ for k, r in aws_apigatewayv2_route.routes : k => r.id }` facilita integração com outros módulos.

## Comandos úteis

```bash
terraform init
terraform validate
terraform plan -var-file=env/dev.tfvars
```

## Sugestões de melhoria (próximos passos)
- Implementar a criação opcional de um `aws_apigatewayv2_authorizer` quando habilitado por variável (incluindo `issuer` e `audiences`).
- Adicionar `output "routes"` para retornar um mapa das rotas criadas.
- Adicionar validações nas variáveis para evitar rotas `restricted` sem `auth_integration_name`.

## Licença
- Confira a licença no repositório raiz.

---
Atualizado para refletir o estado atual do módulo (variáveis, comportamento e outputs).
