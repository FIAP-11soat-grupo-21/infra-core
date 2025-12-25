# Módulo Cognito (AWS Cognito User Pool e Client)

Este módulo cria um Cognito User Pool e um User Pool Client com configurações básicas e retornará os identificadores necessários para integração com aplicações.

Objetivos
- Criar User Pool e Client configuráveis (políticas de token, atributos exigidos, etc.).

Requisitos
- Terraform 0.12+ e provider AWS configurado no módulo raiz.

Uso

```hcl
module "cognito" {
  source = "../../modules/cognito"

  user_pool_name                = "my-app-users"
  project_name                  = "myproject"
  allow_admin_create_user_only  = false
  auto_verified_attributes      = ["email"]
  username_attributes           = ["email"]
  email_required                = true
  generate_secret               = true
  access_token_validity         = 60
  id_token_validity             = 60
  refresh_token_validity        = 30
  tags = {
    Environment = var.environment
    Project     = "myproject"
  }
}
```

Inputs (variáveis)

| Nome | Tipo | Default | Descrição |
|------|------|---------|-----------|
| `user_pool_name` | string | n/a | Nome do Cognito User Pool. |
| `project_name` | string | n/a | Nome do projeto. |
| `allow_admin_create_user_only` | bool | `false` | Indica se apenas admins podem criar usuários. |
| `auto_verified_attributes` | list(string) | `[]` | Atributos que serão auto-verificados (ex.: `email`). |
| `username_attributes` | list(string) | `[]` | Atributos usados como username (ex.: `email`). |
| `email_required` | bool | `false` | Define se email é obrigatório. |
| `name_required` | bool | `false` | Define se o atributo `name` é obrigatório. |
| `generate_secret` | bool | `true` | Indica se o client deve gerar `client_secret`. |
| `access_token_validity` | number | `60` | Validade do access token em minutos. |
| `id_token_validity` | number | `60` | Validade do id token em minutos. |
| `refresh_token_validity` | number | `30` | Validade do refresh token em dias. |
| `tags` | map(string) | `{}` | Tags aplicadas aos recursos. |

Outputs

| Nome | Tipo | Descrição |
|------|------|-----------|
| `user_pool_id` | string | ID do Cognito User Pool criado. |
| `user_pool_arn` | string | ARN do Cognito User Pool. |
| `user_pool_client_id` | string | ID do User Pool Client criado. |
| `user_pool_client_secret` | string (sensitive) | Secret do User Pool Client (sensível). |

Boas práticas
- Proteja o `user_pool_client_secret` em ferramentas de CI/CD e vaults — ele é marcado como sensível.
- Configure atributos e políticas de senha conforme requisitos de segurança da sua organização.

Comandos úteis

```bash
terraform init
terraform validate
terraform plan -var-file=env/dev.tfvars
```

