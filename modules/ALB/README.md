# Módulo ALB (Application Load Balancer)

Este módulo cria um Application Load Balancer (ALB) integrado ao AWS Target Group e Listener padrão.

Objetivos:
- Prover um ALB configurável (interno ou público).
- Expor outputs úteis para consumo por outros módulos (DNS, ARNs, SG, Listener, Target Group).

Requisitos
- Terraform 0.12+ (ou versão usada no seu pipeline). Ajuste o bloco `required_version` conforme sua política.
- Provider AWS configurado no módulo raiz (ou passado via provider alias).

Uso

Exemplo de chamada do módulo:

```hcl
module "alb" {
  source             = "../../modules/ALB"

  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids # Para ALB interno use subnets privadas; para internet-facing use subnets públicas mesmo sem trocar o nome da variável
  app_port           = 80
  health_check_path  = "/health"

  project_common_tags = {
    Environment = var.environment
    Project     = "myapp"
  }

  loadbalancer_name = "myapp"
  is_internal       = true
}
```

Exemplo de como consumir outputs do módulo:

```hcl
output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "alb_security_group" {
  value = module.alb.alb_security_group_id
}
```

Inputs (variáveis)

| Nome                  | Tipo         | Default   | Descrição                                                                                                        |
|-----------------------|--------------|-----------|------------------------------------------------------------------------------------------------------------------|
| `vpc_id`              | string       | n/a       | Id da VPC onde o ALB será criado. (obrigatório)                                                                  |
| `private_subnet_ids`  | list(string) | n/a       | Lista de IDs das subnets onde o ALB será criado. Para ALB internet-facing, passe subnets públicas. (obrigatório) |
| `app_port`            | number       | `80`      | Porta onde a aplicação está escutando (target port).                                                             |
| `health_check_path`   | string       | `/`       | Caminho usado pelo health check do Target Group.                                                                 |
| `project_common_tags` | map(string)  | `{}`      | Tags comuns aplicadas aos recursos do ALB.                                                                       |
| `loadbalancer_name`   | string       | `"myapp"` | Nome base para o ALB. Será usado para identificar o recurso.                                                     |
| `is_internal`         | bool         | `true`    | Define se o ALB é interno (`true`) ou público (`false`).                                                         |

Observações sobre inputs
- `private_subnet_ids`: apesar do nome, se `is_internal = false` você deverá fornecer subnets públicas para que o ALB seja acessível pela internet. O módulo não altera nomes de variável por compatibilidade com usos existentes.
- Sempre passe pelo menos duas subnets em zonas diferentes para alta disponibilidade.

Outputs

| Nome | Tipo | Descrição |
|------|------|-----------|
| `alb_arn` | string | ARN do Application Load Balancer (ALB). |
| `alb_dns_name` | string | Nome DNS do ALB (ex.: `example-alb-123456.us-east-1.elb.amazonaws.com`). |
| `alb_security_group_id` | string | ID do Security Group associado ao ALB. |
| `target_group_arn` | string | ARN do Target Group utilizado pelo ALB. |
| `listener_arn` | string | ARN do Listener do ALB. |

Exemplo prático de uso em outro módulo

Suponha que um módulo de serviço precise do DNS do ALB para configurar registros DNS ou variáveis de ambiente:

```hcl
module "service" {
  source = "../modules/service"

  alb_dns = module.alb.alb_dns_name
  alb_tg_arn = module.alb.target_group_arn
}
```

Boas práticas
- Versionamento: fixe a versão do módulo no root (ex.: via Git tag ou registry) ao utilizar em múltiplos ambientes.
- Segregação de responsabilidades: mantenha a criação do ALB neste módulo e a criação de registros DNS (Route53) em um módulo separado que consuma `module.alb.alb_dns_name`.
- Segurança: restrinja o Security Group do ALB para only as portas/ips necessários; considere usar WAF se o ALB for público.
- Testes: após instanciar o módulo, rode `terraform validate` e `terraform plan` em ambiente de staging antes de aplicar em produção.

Comandos úteis

```bash
terraform init
terraform validate
terraform plan -var-file=env/dev.tfvars
```

Licença
- Este módulo não inclui uma licença específica; verifique o repositório raiz para informações de licença.

