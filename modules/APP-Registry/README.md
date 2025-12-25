# Módulo APP-Registry (AWS Service Catalog AppRegistry)

Este módulo cria um recurso do AWS Service Catalog AppRegistry para registrar metadados de um projeto na conta.

Objetivos
- Criar uma aplicação no AppRegistry e expor seu identificador/tag para consumo por outros módulos ou recursos.

Requisitos
- Terraform 0.12+ e provider AWS configurado no módulo raiz.

Uso

```hcl
module "app_registry" {
  source = "../../modules/APP-Registry"

  project_name        = "my-project"
  project_description = "Descrição do projeto"
  project_common_tags = {
    Environment = var.environment
    Team        = "platform"
  }
  environment = "dev"
}
```

Inputs (variáveis)

| Nome | Tipo | Default | Descrição |
|------|------|---------|-----------|
| `project_name` | string | n/a | Nome do projeto (usado para criar a aplicação no AppRegistry). |
| `project_description` | string | `null` | Descrição opcional do projeto. |
| `project_common_tags` | map(string) | `{}` | Tags aplicadas aos recursos. |
| `environment` | string | `dev` | Ambiente (ex.: dev, staging, prod). |

Outputs

| Nome | Tipo | Descrição |
|------|------|-----------|
| `app_registry_application_tag` | string | Nome/tag da Application Registry criada (valor de `aws_servicecatalogappregistry_application.app_catalog.application_tag`). |

Boas práticas
- Use o AppRegistry para centralizar metadados do seu projeto e facilitar governança e inventário.
- Garanta que tags e nomes sejam consistentes entre módulos para facilitar buscas e auditoria.

Comandos úteis

```bash
terraform init
terraform validate
terraform plan -var-file=env/dev.tfvars
```

