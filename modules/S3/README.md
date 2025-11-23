# Módulo S3

## Descrição

Cria um bucket S3 com configurações comuns: versionamento, bloqueio de acesso público, criptografia server-side (KMS opcional) e regra de lifecycle opcional.

## Entradas (inputs)

| Nome | Tipo | Obrigatório | Descrição |
|------|------|:----------:|----------|
| bucket_name | string | Sim | Nome próprio do bucket S3. Deve ser único globalmente — NÃO use o nome do projeto |
| acl | string | Não | ACL do bucket (default: "private") |
| force_destroy | bool | Não | Permite destruir o bucket mesmo que contenha objetos (default: false) |
| project_common_tags | map(string) | Não | Tags comuns aplicadas aos recursos (default: {}) |
| enable_versioning | bool | Não | Habilita versionamento (default: true) |
| enable_encryption | bool | Não | Habilita criptografia server-side (default: true) |
| kms_key_id | string | Não | ID da chave KMS (opcional). Se vazio, usa AES256 |
| block_public_acls | bool | Não | Bloquear ACLs públicos (default: true) |
| block_public_policy | bool | Não | Bloquear políticas públicas (default: true) |
| ignore_public_acls | bool | Não | Ignorar ACLs públicos (default: true) |
| restrict_public_buckets | bool | Não | Restringir buckets públicos (default: true) |
| enable_lifecycle_rule | bool | Não | Habilita regra de lifecycle para expirar objetos (default: false) |
| lifecycle_days | number | Não | Dias para expiração quando a regra está habilitada (default: 30) |

## Saídas (outputs)

| Nome | Descrição |
|------|-----------|
| bucket_id | Nome (ID) do bucket criado |
| bucket_arn | ARN do bucket |
| bucket_domain_name | Nome de domínio do bucket (ex.: bucket.s3.amazonaws.com) |

## Exemplo

```hcl
module "storage" {
  source = "../S3"

  bucket_name = "meu-nome-proprio-bucket"
  project_common_tags = {
    Environment = "dev"
    Owner       = "team-a"
  }

  # opções opcionais
  enable_versioning = true
  enable_encryption = true
  # kms_key_id = "arn:aws:kms:..."
}
```

## Notas
- O `bucket_name` deve ser único globalmente. Por segurança e organização, use um nome próprio (por exemplo: `meu-nome-proprio-bucket`) e NÃO utilize apenas o nome do projeto.
- Se precisar que o bucket permita conteúdo público (ex.: site estático), ajuste conscientemente as configurações de `public_access_block`.
