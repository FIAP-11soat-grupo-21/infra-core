# Módulo SM (Secrets Manager)

## Descrição

Este módulo cria segredos no AWS Secrets Manager e retorna o ARN do secret.

## Entradas (inputs)

| Nome | Tipo | Obrigatório | Descrição |
|------|------|:----------:|----------|
| project_common_tags | map(string) | Sim | Tags comuns do projeto |
| project_name | string | Sim | Nome do projeto |
| secret_name | string | Sim | Nome do secret a ser criado |
| secret_content | map(string) | Sim | Conteúdo do secret (pares chave/valor) |

## Saídas (outputs)

| Nome | Descrição |
|------|-----------|
| secret_arn | ARN do secret criado |

## Exemplo

```hcl
module "ghcr_secret" {
  source = "../SM"
  project_common_tags = local.project_common_tags
  project_name = var.project_name
  secret_name = "${var.project_name}9-ghcr"
  secret_content = var.secret_content
}
```

## Notas
- Proteja o arquivo `values.tfvars` e quaisquer lugares onde segredos possam ser expostos.
