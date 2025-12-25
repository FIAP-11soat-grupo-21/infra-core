# Módulo S3

Este módulo cria um bucket S3 com opções de versionamento, criptografia, políticas de bloqueio público e regras de ciclo de vida.

Objetivos
- Prover um bucket S3 seguro e configurável para armazenar objetos de aplicação, artefatos ou backups.

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
  project_common_tags = { Environment = var.environment }
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

Outputs

| Nome | Tipo | Descrição |
|------|------|-----------|
| `bucket_id` | string | ID (nome) do bucket S3. |
| `bucket_name` | string | Nome do bucket (alias para `bucket_id`). |
| `bucket_arn` | string | ARN do bucket. |
| `bucket_domain_name` | string | Nome de domínio do bucket (ex.: `bucket.s3.amazonaws.com`). |
| `bucket_regional_domain_name` | string | Nome de domínio regional do bucket. |

Boas práticas
- Evite `force_destroy = true` em produção sem um processo de backup/replicação.
- Utilize políticas e bloqueios públicos para prevenir exposição acidental de dados.

Comandos úteis

```bash
terraform init
terraform validate
terraform plan -var-file=env/dev.tfvars
```

