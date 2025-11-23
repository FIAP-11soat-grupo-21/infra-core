# Módulo RDS

## Descrição

Cria uma instância RDS (ex.: Postgres), subnet group, security group e Secrets Manager para armazenar credenciais.

## Entradas (inputs)

| Nome | Tipo | Obrigatório | Descrição |
|------|------|:----------:|----------|
| project_common_tags | map(string) | Sim | Tags comuns do projeto |
| project_name | string | Sim | Nome do projeto |
| db_port | number | Sim | Porta do banco (ex.: 5432) |
| db_allocated_storage | number | Não | Armazenamento alocado (GB) |
| db_storage_type | string | Não | Tipo de armazenamento (gp2, io1, etc) |
| db_engine | string | Sim | Moto do DB (ex.: postgres) |
| db_engine_version | string | Não | Versão do motor |
| db_instance_class | string | Não | Classe da instância (ex.: db.t3.micro) |
| db_username | string | Sim | Usuário do banco |
| private_subnets | list(string) | Sim | Subnets privadas para o DB |
| vpc_id | string | Sim | ID da VPC |

## Saídas (outputs)

| Nome | Descrição |
|------|-----------|
| db_connection | Endpoint do banco (host) |
| db_secret_password_arn | ARN do Secret com a senha gerada |

## Exemplo

```hcl
module "rds_postgres" {
  source = "../RDS"
  project_common_tags = local.project_common_tags
  project_name = var.project_name
  db_port = var.db_port
  db_allocated_storage = var.db_allocated_storage
  db_storage_type = var.db_storage_type
  db_engine = var.db_engine
  db_engine_version = var.db_engine_version
  db_instance_class = var.db_instance_class
  db_username = var.db_username
  private_subnets = module.vpc.private_subnets
  vpc_id = module.vpc.vpc_id
}
```

## Notas
- Para ambientes de produção, reveja configurações de backups, multi-AZ e performance (I/O).
