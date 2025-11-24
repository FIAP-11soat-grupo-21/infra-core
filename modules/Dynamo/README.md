# Módulo Dynamo (DynamoDB)

Este módulo cria uma tabela Amazon DynamoDB e uma policy IAM pronta para dar acesso à essa tabela.

Use este README para: 1) referenciar o módulo no seu root module; 2) expor os outputs (nome/ARN) para uma AWS Lambda ou para containers no ECS; 3) anexar a policy gerada a uma role (Lambda / ECS task role).

Resumo rápido
- Local: `modules/Dynamo`
- Recursos criados: `aws_dynamodb_table.this` e `aws_iam_policy.access_policy`
- Outputs principais: `table_name`, `table_arn`, `table_stream_arn`, `policy_arn`

Uso do módulo

Exemplo mínimo (no root module):

```
module "dynamo" {
  source = "./modules/Dynamo"

  name         = "minha-tabela"
  hash_key     = "id"
  hash_key_type = "S"
  # ajuste as variáveis conforme necessário
}
```

Principais inputs (resumo)

| Nome da variável | Tipo | Obrigatório | Default | Descrição |
| --- | --- | ---: | --- | --- |
| `name` | string | Sim | (nenhum) | Nome da tabela (obrigatório) |
| `hash_key` | string | Sim | (nenhum) | Atributo de chave de partição |
| `hash_key_type` | string | Não | `S` | Tipo do atributo de chave de partição (`S`, `N`, `B`) |
| `range_key` | string | Não | `""` | Atributo de chave de ordenação (opcional) |
| `range_key_type` | string | Não | `S` | Tipo do atributo de chave de ordenação |
| `billing_mode` | string | Não | `PAY_PER_REQUEST` | `PAY_PER_REQUEST` (on-demand) ou `PROVISIONED` |
| `read_capacity` | number | Não | `5` | Leituras provisionadas (quando `billing_mode = "PROVISIONED"`) |
| `write_capacity` | number | Não | `5` | Escritas provisionadas (quando `billing_mode = "PROVISIONED"`) |
| `global_secondary_indexes` | list(object) | Não | `[]` | Lista de GSIs (ver `variables.tf` para o shape esperado) |
| `sse_enabled` | bool | Não | `false` | Ativa Server-Side Encryption (KMS) |
| `kms_key_arn` | string | Não | `""` | ARN da chave KMS (quando `sse_enabled = true`) |
| `ttl_enabled` | bool | Não | `false` | Ativa TTL na tabela |
| `ttl_attribute` | string | Não | `""` | Nome do atributo usado para TTL |
| `stream_enabled` | bool | Não | `false` | Ativa DynamoDB Streams |
| `stream_view_type` | string | Não | `NEW_AND_OLD_IMAGES` | Tipo de visualização do stream |
| `pitr` | bool | Não | `false` | Habilita Point-in-Time Recovery |
| `tags` | map(string) | Não | `{}` | Tags aplicadas diretamente à tabela |
| `read_only` | bool | Não | `false` | Quando true, a policy gerada permite apenas ações de leitura |
| `project_common_tags` | map(string) | Não | `{}` | Tags comuns do projeto que serão mescladas |
| `project_name` | string | Não | `""` | Nome do projeto (opcional) |

Outputs
- `table_name` - nome da tabela (string)
- `table_arn` - ARN da tabela (string)
- `table_stream_arn` - ARN do stream (ou `null` se não configurado)
- `policy_arn` - ARN da policy IAM criada pelo módulo

Como permitir que uma Lambda acesse a tabela

Opção A — Anexar a policy gerada pelo módulo à role da Lambda (recomendado quando a policy do módulo tem o conjunto de permissões desejado):

```
# role da lambda (exemplo simplificado)
resource "aws_iam_role" "lambda_role" {
  name = "lambda-dynamo-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "attach_dynamo" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = module.dynamo.policy_arn
}

resource "aws_lambda_function" "app" {
  function_name = "minha-func"
  role          = aws_iam_role.lambda_role.arn
  # outros campos: filename, handler, runtime, etc.

  environment {
    variables = {
      DDB_TABLE_NAME = module.dynamo.table_name
      DDB_TABLE_ARN  = module.dynamo.table_arn
    }
  }
}
```

Opção B — Criar uma policy inline/mais restrita usando `module.dynamo.table_arn` (quando quiser customizar ações):

```
resource "aws_iam_role_policy" "lambda_dynamo_policy" {
  name = "lambda-dynamo-inline"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ],
        Resource = [
          module.dynamo.table_arn,
          "${module.dynamo.table_arn}/index/*"
        ]
      }
    ]
  })
}
```

Como permitir que uma task do ECS acesse a tabela

- Atribua a policy (ou a policy gerada pelo módulo) à `task_role` usada pela definição de tarefa.
- Passe `module.dynamo.table_name` e/ou `module.dynamo.table_arn` como variáveis de ambiente na `container_definitions`.

Exemplo:

```
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_attach_dynamo" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = module.dynamo.policy_arn
}

module "ecs" {
  source = "./modules/ECS-Service"
  cluster_id = aws_ecs_cluster.main.id
  ecs_security_group_id = aws_security_group.ecs.id
  task_execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn
  private_subnet_ids = var.private_subnet_ids
  ecs_container_name = "app"
  ecs_container_image = "meu-registro/minha-imagem:latest"
  ecs_container_port = 8080
  ecs_container_environment_variables = {
    DDB_TABLE_NAME = module.dynamo.table_name
  }
}
```

Se preferir que o `modules/ECS-Service` crie a `task role` automaticamente

- O módulo `ECS-Service` cria uma task role internamente quando você NÃO fornece `task_role_arn` ao instanciá-lo; nesse caso ele expõe a ARN dessa role como output `module.ecs.task_role_arn`.
- Recomendação: anexe a policy do Dynamo externamente ao role criado (para manter responsabilidades separadas). Abaixo um exemplo de como fazer isso extraindo o nome da role a partir do ARN retornado pelo módulo:

```
# instancia o ECS sem fornecer task_role_arn (role será criada internamente)
module "ecs" {
  source = "./modules/ECS-Service"
  cluster_id = aws_ecs_cluster.main.id
  ecs_security_group_id = aws_security_group.ecs.id
  task_execution_role_arn = aws_iam_role.ecs_execution_role.arn
  private_subnet_ids = var.private_subnet_ids
  ecs_container_name = "app"
  ecs_container_image = "meu-registro/minha-imagem:latest"
  ecs_container_port = 8080
}

# depois (pode ser no mesmo root module) anexa a policy do dynamo à role criada pelo módulo
locals {
  ecs_task_role_name = length(module.ecs.task_role_arn) > 0 ? split("/", module.ecs.task_role_arn)[1] : ""
}

resource "aws_iam_role_policy_attachment" "attach_dynamo_to_ecs_role" {
  count = local.ecs_task_role_name != "" ? 1 : 0
  role       = local.ecs_task_role_name
  policy_arn = module.dynamo.policy_arn
}
```

Observação sobre rede

- Se suas tasks ECS rodarem em subnets privadas sem saída para a Internet (assign_public_ip = false), garanta que exista:
  - um NAT Gateway/Instance nas route tables privadas; ou
  - um `aws_vpc_endpoint` do tipo Gateway para DynamoDB (recomendado) para manter o tráfego dentro da rede AWS.

- Mesmo quando a conectividade de rede está disponível, a autorização para acessar a tabela depende da IAM role da task (veja `task_role_arn` no exemplo acima).

Boas práticas
- Não exponha credenciais em variáveis de ambiente; use roles (Lambda role / ECS task role).
- Prefira anexar a policy já criada por este módulo quando ela contém o conjunto de permissões correto. Caso contrário, gere uma policy inline mais restrita usando `module.dynamo.table_arn`.
- Reduza o escopo de permissões (ações e ARNs) ao mínimo necessário.