# Módulo API-Gateway-Function-Route

Descrição

Cria integração e rota no API Gateway v2 (HTTP API) para invocar uma função Lambda (AWS_PROXY). Também cria a permissão (`aws_lambda_permission`) necessária para que o API Gateway invoque a Lambda.

Entradas (inputs)

| Nome | Tipo | Obrigatório | Descrição |
|------|------|:----------:|----------|
| api_id | string | Sim* | ID da API (apigatewayv2) onde criar a integração |
| route_key | string | Sim* | Rota / método a ser criada (ex: `GET /path` ou `$default`) |
| lambda_arn | string | Sim* | ARN da função Lambda que será integrada |
| lambda_name | string | Não | Nome amigável usado na composição do statement_id (opcional) |
| payload_format_version | string | Não | Versão do payload (padrão `2.0`) |

* O módulo cria os recursos somente quando `api_id`, `route_key` e `lambda_arn` forem informados.

Saídas (outputs)

| Nome | Descrição |
|------|-----------|
| integration_id | ID da integração criada (se criada) |
| route_id | ID da rota criada (se criada) |
| permission_statement_id | statement_id criado na permissão lambda (se criada) |

Exemplo

```hcl
module "api_fn_route" {
  source = "../API-Gateway-Function-Route"
  api_id = module.api_gateway.api_id
  route_key = "GET /orders"
  lambda_arn = module.lambda.my_lambda.lambda_arn
  lambda_name = "orders-fn"
}
```

Notas
- O módulo só cria os recursos quando as variáveis obrigatórias estiverem preenchidas (evita criação acidental quando usado como sub-módulo).
- Após a criação, você ainda precisa criar um deployment/stage no API Gateway principal se desejar expor a nova rota publicamente.

