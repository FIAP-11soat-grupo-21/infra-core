# Módulo Lambda

Este módulo cria uma função Lambda com suporte a execução em VPC, layers opcionais e integração com API Gateway v2.

Objetivos
- Provisionar Lambda function com configurações de runtime, memória, timeout, VPC, layers e permissões mínimas.

Requisitos
- Terraform 0.12+ e provider AWS configurado.

Uso

```hcl
module "lambda" {
  source = "../../modules/Lambda"

  lambda_name = "my-function"
  runtime     = "python3.9"
  handler     = "handler.handler"
  subnet_ids  = module.vpc.private_subnet_ids
  vpc_id      = module.vpc.vpc_id
  environment = { ENV = var.environment }
  layer_enabled = false
  timeout = 30
  memory_size = 256
  lambda_reserved_concurrent_executions    = 20
  lambda_provisioned_concurrent_executions = 5
  role_permissions = {}
  api_id = module.api_gateway.api_id
}
```

Inputs (variáveis)

| Nome | Tipo | Default | Descrição |
|------|------|---------|-----------|
| `lambda_name` | string | n/a | Nome da função Lambda. |
| `handler` | string | `handler.handler` | Handler da função. |
| `runtime` | string | `python3.9` | Runtime da função Lambda. |
| `environment` | map(string) | `{}` | Variáveis de ambiente para a função. |
| `subnet_ids` | list(string) | n/a | Subnets onde a Lambda ficará (para acesso VPC). |
| `tags` | map(string) | `{}` | Tags aplicadas aos recursos. |
| `vpc_id` | string | n/a | ID da VPC (para criar security group). |
| `layer_enabled` | bool | `false` | Habilita criação e anexação de layer. |
| `layer_source_path` | string | `""` | Path para conteúdo do layer (se habilitado). |
| `layer_name` | string | `""` | Nome do layer. |
| `layer_compatible_runtimes` | list(string) | `[]` | Runtimes compatíveis com o layer. |
| `layer_compatible_architectures` | list(string) | `[]` | Arquiteturas compatíveis com o layer. |
| `layer_description` | string | `""` | Descrição do layer. |
| `layer_license_info` | string | `""` | Informação de licença do layer. |
| `s3_bucket` | string | `""` | Bucket S3 contendo o package da Lambda (opcional). |
| `s3_key` | string | `""` | Key do objeto zip no S3. |
| `timeout` | number | `30` | Timeout da função em segundos. |
| `memory_size` | number | `256` | Memória da função em MB. |
| `lambda_reserved_concurrent_executions` | number | `null` | Limite de concorrência reservada da função (opcional). |
| `lambda_provisioned_concurrent_executions` | number | `null` | Concorrência provisionada para a versão publicada (opcional). |
| `role_permissions` | map(object) | `{}` | Mapa de permissões para anexar à role da Lambda. |
| `api_id` | string | n/a | API Gateway v2 API id (se for integrar). |
| `payload_format_version` | string | `2.0` | Versão do payload para integração com API Gateway v2. |

Outputs

| Nome | Tipo | Descrição |
|------|------|-----------|
| `lambda_arn` | string | ARN da função Lambda criada. |
| `vpc_subnet_ids` | list(string) | Subnet IDs usados pela função (echo das entradas). |
| `lambda_integration_id` | string | ID da integração criada com API Gateway v2 (se aplicável). |

Boas práticas
- Forneça subnets em pelo menos 2 AZs para alta disponibilidade.
- Use layers para compartilhar dependências comuns entre funções.
- Proteja IAM roles com permissões mínimas necessárias.

Comandos úteis

```bash
terraform init
terraform validate
terraform plan -var-file=env/dev.tfvars
```

