# Módulo API-Gateway (HTTP API - API Gateway v2)

Este módulo cria uma API Gateway HTTP (v2) com VPC Link para conectar um ALB interno através de integration HTTP. É pensado para expor serviços atrás de um ALB usando o API Gateway como ponto de entrada.

Objetivos
- Criar a API Gateway (http api v2) e o VPC Link para integração com ALB.
- Fornecer recursos prontos para deploy (stage, integração, permissões) com configurações mínimas.

Requisitos
- Terraform 0.12+ (ou versão utilizada no pipeline).
- Provider AWS configurado no módulo raiz.

Exemplo de uso

```hcl
module "api_gateway" {
  source = "../../modules/API-Gateway"

  project_name         = "myproject"
  project_common_tags  = {
    Environment = var.environment
    Project     = "myproject"
  }
  api_name             = "my-http-api"
  private_subnet_ids   = module.alb.private_subnet_ids
  alb_security_group_id= module.alb.alb_security_group_id
  gwapi_auto_deploy    = true
  stage_name           = "prod"
}
```

Inputs (variáveis)

| Nome | Tipo | Default | Descrição |
|------|------|---------|-----------|
| `project_name` | string | n/a | Nome do projeto para identificação dos recursos. (obrigatório) |
| `project_common_tags` | map(string) | `{}` | Tags comuns aplicadas aos recursos. |
| `api_name` | string | `"MyHTTPAPI"` | Nome da API Gateway (opcional). |
| `private_subnet_ids` | list(string) | n/a | Lista de subnets privadas onde o VPC Link criará ENIs (deve incluir as subnets do ALB). (obrigatório) |
| `alb_security_group_id` | string | n/a | ID do Security Group do ALB para permitir tráfego do VPC Link. (obrigatório) |
| `gwapi_auto_deploy` | bool | `true` | Habilita o auto-deploy para a API Gateway. |
| `stage_name` | string | n/a | Nome do stage criado na API Gateway (ex.: `dev`, `prod`). (obrigatório) |

Observações sobre inputs
- `private_subnet_ids`: forneça subnets em múltiplas AZs para redundância.
- `alb_security_group_id`: normalmente é o SG do ALB, garanta regras permitindo tráfego do VPC Link.

Outputs

| Nome | Tipo | Descrição |
|------|------|-----------|
| `api_id` | string | ID da API Gateway v2 (http api) criada pelo módulo. |

Exemplo prático

- Use `module.api_gateway.api_id` para criar rotas, integrações adicionais ou para expor a API via custom domain (Route53 e Certificate Manager são gerenciados externamente no seu pipeline).

Boas práticas
- Separe a responsabilidade de registrar domínios, emitir certificados e criar registros DNS em módulos específicos.
- Utilize variáveis e tags para rastreabilidade em ambientes multi-ambiente.
- Sempre rode `terraform validate` e `terraform plan` antes de aplicar.

Comandos úteis

```bash
terraform init
terraform validate
terraform plan -var-file=env/dev.tfvars
```

Licença
- Verifique o repositório raiz para informações sobre licença.

Contato
- Atualize o README do repositório raiz com convenções do time para uso de módulos.

