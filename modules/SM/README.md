# Módulo SM (Secrets Manager)

Este módulo cria um secret no AWS Secrets Manager contendo pares chave/valor passados como mapa.

Objetivos
- Centralizar segredos da aplicação e expor o ARN/ID (se necessário via output). 

Requisitos
- Terraform 0.12+ e provider AWS configurado.

Uso

```hcl
module "secrets" {
  source = "../../modules/SM"

  project_name   = "myproject"
  secret_name    = "myapp/credentials"
  secret_content = {
    DB_USER = "admin"
    DB_PASS = "s3cr3t"
  }
}
```

Inputs (variáveis)

| Nome | Tipo | Default | Descrição |
|------|------|---------|-----------|
| `project_name` | string | n/a | Nome do projeto. |
| `project_common_tags` | map(string) | `{}` | Tags aplicadas aos recursos. |
| `secret_name` | string | n/a | Nome do secret no Secrets Manager. |
| `secret_content` | map(string) | n/a | Conteúdo do secret em pares chave/valor. |

Outputs

Esse módulo atualmente não expõe outputs explicitamente. Caso precise do ARN ou do id do secret, posso adicionar outputs opcionais (por exemplo `secret_arn` e `secret_id`).

Boas práticas
- Nunca armazene secrets em repositórios de código.
- Utilize políticas de rotação e controle de acesso para os secrets.

Comandos úteis

```bash
terraform init
terraform validate
terraform plan -var-file=env/dev.tfvars
```

