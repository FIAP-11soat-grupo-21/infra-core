# Módulo APP-Registry

## Descrição

Cria recursos do Application Registry (opcional) para marcar o projeto na AWS.

## Entradas (inputs)

| Nome | Tipo | Obrigatório | Descrição |
|------|------|:----------:|----------|
| project_common_tags | map(string) | Sim | Tags comuns do projeto |
| project_name | string | Sim | Nome do projeto |
| project_description | string | Não | Descrição do projeto |

## Saídas (outputs)

| Nome | Descrição |
|------|-----------|
| app_registry_application_tag | map(string) | Tag gerada para ser mesclada com tags de outros módulos |

## Exemplo

```hcl
module "application_registry" {
  source = "../APP-Registry"
  project_common_tags = local.project_common_tags
  project_name = var.project_name
  project_description = var.project_description
}
```
