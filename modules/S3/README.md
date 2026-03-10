# Módulo S3

Este módulo cria um bucket S3 com opções de versionamento, criptografia, políticas de bloqueio público, regras de ciclo de vida e **notificações para SNS/SQS**.

Objetivos
- Prover um bucket S3 seguro e configurável para armazenar objetos de aplicação, artefatos ou backups.
- Enviar notificações automáticas para SNS ou SQS quando arquivos são adicionados, removidos ou modificados.

Requisitos
- Terraform 0.12+ e provider AWS configurado.

Uso

```hcl
module "s3_bucket" {
  source = "../../modules/S3"

  bucket_name = "my-app-artifacts"
  enable_versioning = true
  enable_encryption = true
  kms_key_id = ""
  
  # Habilitar notificações para SNS
  enable_notifications = true
  notification_topic_arn = module.my_sns_topic.topic_arn
  notification_events = ["s3:ObjectCreated:*"]
  
  project_common_tags = { Environment = var.environment }
}
```

## 📬 Notificações S3

Este módulo suporta notificações automáticas para SNS e SQS. Veja o [**Guia Completo de Notificações**](./NOTIFICATIONS_GUIDE.md) para exemplos detalhados e casos de uso.

### Exemplo Rápido: Notificar quando arquivos JSON são adicionados

```hcl
module "s3_bucket" {
  source = "../../modules/S3"

  bucket_name          = "my-data-bucket"
  enable_notifications = true
  notification_queue_arn = module.my_sqs_queue.queue_arn
  notification_filter_suffix = ".json"
  notification_events = ["s3:ObjectCreated:*"]
  
  project_common_tags = var.project_common_tags
}
```

Inputs (variáveis)

| Nome | Tipo | Default | Descrição |
|------|------|---------|-----------|
| `bucket_name` | string | n/a | Nome global do bucket (obrigatório). |
| `acl` | string | `private` | ACL do bucket. |
| `force_destroy` | bool | `false` | Permite destruir bucket mesmo com objetos. |
| `project_common_tags` | map(string) | `{}` | Tags aplicadas aos recursos. |
| `enable_versioning` | bool | `true` | Habilita versionamento. |
| `enable_encryption` | bool | `true` | Habilita criptografia server-side. |
| `kms_key_id` | string | `""` | ID da chave KMS para SSE (opcional). |
| `block_public_acls` | bool | `true` | Bloquear ACLs públicos. |
| `block_public_policy` | bool | `true` | Bloquear políticas públicas. |
| `ignore_public_acls` | bool | `true` | Ignorar ACLs públicos. |
| `restrict_public_buckets` | bool | `true` | Restringir buckets públicos. |
| `enable_lifecycle_rule` | bool | `false` | Habilita regra de lifecycle que expira objetos. |
| `lifecycle_days` | number | `30` | Dias para expirar objetos quando `enable_lifecycle_rule` é `true`. |
| **`enable_notifications`** | **bool** | **`false`** | **Habilita notificações S3 para SNS/SQS.** |
| **`notification_topic_arn`** | **string** | **`""`** | **ARN do tópico SNS para notificações.** |
| **`notification_queue_arn`** | **string** | **`""`** | **ARN da fila SQS para notificações.** |
| **`notification_events`** | **list(string)** | **`["s3:ObjectCreated:*"]`** | **Eventos S3 que disparam notificações.** |
| **`notification_filter_prefix`** | **string** | **`""`** | **Prefixo do caminho (ex: `uploads/`).** |
| **`notification_filter_suffix`** | **string** | **`""`** | **Sufixo/extensão (ex: `.json`).** |

Outputs

| Nome | Tipo | Descrição |
|------|------|-----------|
| `bucket_id` | string | ID (nome) do bucket S3. |
| `bucket_name` | string | Nome do bucket (alias para `bucket_id`). |
| `bucket_arn` | string | ARN do bucket. |
| `bucket_domain_name` | string | Nome de domínio do bucket (ex.: `bucket.s3.amazonaws.com`). |
| `bucket_regional_domain_name` | string | Nome de domínio regional do bucket. |
| **`sqs_queue_policy_json`** | **string** | **Política JSON para permitir que o S3 envie mensagens para SQS.** |

Boas práticas
- Evite `force_destroy = true` em produção sem um processo de backup/replicação.
- Utilize políticas e bloqueios públicos para prevenir exposição acidental de dados.
- Use notificações SNS/SQS para processar arquivos automaticamente (pipelines de dados, processamento de imagens, etc.).
- Para usar SQS diretamente, recomenda-se usar SNS → SQS (o módulo SQS já suporta isso).

Comandos úteis

```bash
terraform init
terraform validate
terraform plan -var-file=env/dev.tfvars
```



