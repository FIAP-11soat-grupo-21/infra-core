# Módulo VPC

## Descrição

Cria VPC, subnets públicas/privadas, internet gateway, route tables e recursos de rede básicos.

## Entradas (inputs)

| Nome | Tipo | Obrigatório | Descrição |
|------|------|:----------:|----------|
| project_common_tags | map(string) | Sim | Tags comuns do projeto |
| vpc_cidr | string | Não | CIDR da VPC (default definido no root) |
| private_subnet_cidr | string | Não | CIDR da sub-rede privada |
| public_subnet_cidr | string | Não | CIDR da sub-rede pública |

## Saídas (outputs)

| Nome | Descrição |
|------|-----------|
| vpc_id | ID da VPC criada |
| private_subnets | Lista de IDs das subnets privadas |
| public_subnet | ID da subnet pública principal |

## Exemplo

```hcl
module "vcp" {
  source = "../VPC"
  project_common_tags = local.project_common_tags
  vpc_cidr = var.vpc_cidr
  vpc_name = var.project_name
  private_subnet_cidr = var.private_subnet_cidr
  public_subnet_cidr = var.public_subnet_cidr
}
```

## Notas
- Se precisar de NAT Gateway para acesso à Internet a partir de subnets privadas, acrescente a configuração ao módulo.
