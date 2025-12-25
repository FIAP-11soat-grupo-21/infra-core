# Módulo Dynamo (DynamoDB table)

Este módulo cria uma tabela DynamoDB com suporte a modos de cobrança, índices secundários, TTL, streams e criptografia.

Objetivos
- Provisionar uma tabela DynamoDB configurável e expor informações úteis (nome, ARN, stream ARN).

Requisitos
- Terraform 0.12+ e provider AWS configurado.

Uso

```hcl
module "dynamo" {
  source = "../../modules/Dynamo"

  name        = "my-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key    = "id"
  hash_key_type = "S"
  tags = {
    Environment = var.environment
    Project     = "myproject"
  }
}
```

Inputs (variáveis)

| Nome | Tipo | Default | Descrição |
|------|------|---------|-----------|
| `name` | string | n/a | Nome da tabela (obrigatório). |
| `billing_mode` | string | `PAY_PER_REQUEST` | Modo de cobrança (`PAY_PER_REQUEST` ou `PROVISIONED`). |
| `hash_key` | string | n/a | Nome do atributo de hash (partition key). |
| `hash_key_type` | string | `S` | Tipo do hash key (ex.: `S`, `N`). |
| `range_key` | list(object) | `[]` | Configuração opcional de range/Sort keys. |
| `read_capacity` | number | `5` | Capacity units de leitura (quando `PROVISIONED`). |
| `write_capacity` | number | `5` | Capacity units de escrita (quando `PROVISIONED`). |
| `global_secondary_indexes` | list(object) | `[]` | Lista de GSI a criar. |
| `sse_enabled` | bool | `false` | Habilita criptografia com KMS. |
| `kms_key_arn` | string | `""` | ARN da chave KMS para SSE (se aplicável). |
| `ttl_enabled` | bool | `false` | Habilita TTL. |
| `ttl_attribute` | string | `""` | Nome do atributo TTL. |
| `stream_enabled` | bool | `false` | Habilita DynamoDB Streams. |
| `stream_view_type` | string | `NEW_AND_OLD_IMAGES` | Tipo de visualização do stream. |
| `pitr` | bool | `false` | Habilita Point-In-Time Recovery. |
| `tags` | map(string) | `{}` | Tags aplicadas aos recursos. |
| `read_only` | bool | `false` | Indica se a tabela deve ser tratada como somente leitura (comportamento interno do módulo). |
| `project_common_tags` | map(string) | `{}` | Tags comuns do projeto. |
| `secondary_indexes` | list(map(string)) | `[{}]` | Lista de índices secundários a criar. |

Outputs

| Nome | Tipo | Descrição |
|------|------|-----------|
| `table_name` | string | Nome da tabela DynamoDB criada. |
| `table_arn` | string | ARN da tabela. |
| `table_stream_arn` | string/null | ARN do stream (se habilitado) ou `null`. |
| `policy_arn` | string | ARN da policy de acesso criada para a tabela. |

Boas práticas
- Use `PAY_PER_REQUEST` para workloads com tráfego variável; `PROVISIONED` para cargas previsíveis com otimização de custos.
- Ao usar streams, garanta que consumidores (Lambda, Kinesis) sejam configurados para processar os eventos.

Comandos úteis

```bash
terraform init
terraform validate
terraform plan -var-file=env/dev.tfvars
```

