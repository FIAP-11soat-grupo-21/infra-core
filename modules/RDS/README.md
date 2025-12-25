# Módulo RDS

Este módulo provisiona uma instância RDS com configurações de engine, tamanho, storage e subnets privadas.

Objetivos
- Criar uma instância de banco de dados gerenciado (RDS) com configuração básica e networking em subnets privadas.

Requisitos
- Terraform 0.12+ e provider AWS configurado.
- Subnets privadas e security group apropriado.

Uso

```hcl
module "rds" {
  source = "../../modules/RDS"

  project_common_tags   = { Environment = var.environment }
  db_port               = 5432
  db_engine             = "postgres"
  db_engine_version     = "13"
  db_instance_class     = "db.t3.micro"
  db_username           = "admin"
  private_subnets       = module.vpc.private_subnets
  vpc_id                = module.vpc.vpc_id
  app_name              = "myapp"
}
```

Inputs (variáveis)

| Nome | Tipo | Default | Descrição |
|------|------|---------|-----------|
| `project_common_tags` | map(string) | n/a | Tags aplicadas aos recursos. |
| `db_port` | number | n/a | Porta do banco de dados (ex.: 5432). |
| `db_allocated_storage` | number | `20` | Armazenamento em GB. |
| `db_storage_type` | string | n/a | Tipo de armazenamento (`gp2`, `gp3`, etc.). |
| `db_engine` | string | n/a | Motor do banco (ex.: `mysql`, `postgres`). |
| `db_engine_version` | string | n/a | Versão do motor. |
| `db_instance_class` | string | `db.t3.micro` | Classe da instância. |
| `db_username` | string | n/a | Username do banco. |
| `private_subnets` | list(string) | n/a | Lista de subnets privadas para o RDS. |
| `vpc_id` | string | n/a | ID da VPC (se aplicável). |
| `app_name` | string | n/a | Nome da aplicação que irá acessar o RDS. |

Outputs

Este módulo não define outputs atualmente. Se desejar, posso adicionar outputs comuns como `rds_endpoint`, `rds_port`, `rds_instance_id` e `rds_security_group_id`.

Boas práticas
- Procure executar o RDS em subnets privadas com NAT gateways para backups se necessário.
- Configure backups e parâmetros de retenção conforme política do time.

Comandos úteis

```bash
terraform init
terraform validate
terraform plan -var-file=env/dev.tfvars
```

