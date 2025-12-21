# Módulo Lambda

## Descrição

Cria uma função AWS Lambda empacotada a partir de um diretório de código, com role/policies mínimas e obrigatoriamente configurada para rodar dentro de uma VPC (subnets + security groups). Opcionalmente cria integração com API Gateway v2.

## Entradas (inputs)

| Nome | Tipo | Obrigatório | Descrição |
|------|------|:----------:|----------|
| lambda_name | string | Sim | Nome da função Lambda |
| source_path | string | Sim | Caminho para o diretório com o código que será zipado (usado por data.archive_file) |
| handler | string | Não | Handler da função (padrão: `handler.handler`) |
| runtime | string | Não | Runtime usado pela função (ex.: `python3.9`) |
| environment | map(string) | Não | Variáveis de ambiente para a função |
| subnet_ids | list(string) | Sim | IDs das subnets privadas (obrigatório para VPC) |
| security_group_ids | list(string) | Sim | IDs dos security groups aplicados à função (obrigatório para VPC) |
| api_id | string | Não | ID da API Gateway v2 para criar integração (opcional) |
| route_key | string | Não | Route key para criar a rota na API (ex.: `GET /path` ou `$default`) |
| secrets_arn | string | Não | ARN do secret no Secrets Manager consumido pela função (opcional) |
| allow_dynamodb_access | bool | Não | Adiciona permissões dinâmicas para DynamoDB (opcional) |
| dynamo_table_arn | string | Não | ARN da tabela Dynamo para restringir permissões (opcional) |
| tags | map(string) | Não | Tags adicionais para a função |
| role_permissions | map(object) | Não | (Novo) Mapa de permissões opcionais a serem adicionadas à role da Lambda por "método". Cada chave é um identificador e o valor deve conter `actions` (lista de ações), `resources` (lista de ARNs) e opcionalmente `effect` (Allow/Deny). Exemplo:

```hcl
role_permissions = {
  dynamodb = {
    actions = ["dynamodb:GetItem", "dynamodb:PutItem"]
    resources = ["arn:aws:dynamodb:us-east-1:123456789012:table/my-table"]
  }
  s3 = {
    actions = ["s3:GetObject"]
    resources = ["arn:aws:s3:::my-bucket/*"]
  }
}
```

## Saídas (outputs)

| Nome | Descrição |
|------|-----------|
| lambda_arn | ARN da função Lambda criada |
| integration_id | ID da integração com API Gateway v2 (se criada) |
| route_id | ID da rota criada no API Gateway (se criada) |
| vpc_subnet_ids | Lista de subnet IDs atribuídas à função |
| vpc_security_group_ids | Lista de security group IDs atribuídos à função |

## Exemplo de uso

```hcl
module "lambda_example" {
  source = "../Lambda"
  lambda_name = "my-fn"
  source_path = "../modules/my-fn"
  handler = "app.handler"
  runtime = "python3.9"
  subnet_ids = module.vcp.private_subnets
  security_group_ids = [aws_security_group.lambda_sg.id]
  environment = { DB_HOST = module.rds_postgres.db_connection }
  api_id = module.api_gateway.api_id
  route_key = "GET /my-path"
}
```

## Notas

- A função é obrigatoriamente implantada em VPC: forneça `subnet_ids` e `security_group_ids` para que ela tenha conectividade com RDS privado.
- Se a função acessar recursos externos (ex.: DynamoDB público) a partir de subnets privadas, configure NAT Gateway ou VPC Endpoints conforme necessário.
