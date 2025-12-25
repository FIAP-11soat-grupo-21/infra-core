# Módulo VPC

Este módulo cria uma VPC simples com subnets públicas e privadas, e expõe IDs e blocos CIDR.

Objetivos
- Prover uma VPC básica com subnets públicas e privadas para uso de outros módulos (ALB, ECS, RDS, etc.).

Requisitos
- Terraform 0.12+ e provider AWS configurado.

Uso

```hcl
module "vpc" {
  source = "../../modules/VPC"

  vpc_cidr = "10.0.0.0/16"
  vpc_name = "main-vpc"
  private_subnet_cidr = "10.0.1.0/24"
  public_subnet_cidr  = "10.0.2.0/24"
  project_common_tags = { Environment = var.environment }
}
```

Inputs (variáveis)

| Nome | Tipo | Default | Descrição |
|------|------|---------|-----------|
| `vpc_cidr` | string | `10.0.0.0/16` | Bloco CIDR da VPC. |
| `vpc_name` | string | `main-vpc` | Nome da VPC. |
| `project_common_tags` | map(string) | `{}` | Tags aplicadas aos recursos. |
| `private_subnet_cidr` | string | `10.0.1.0/24` | CIDR para a subnet privada. |
| `public_subnet_cidr` | string | `10.0.2.0/24` | CIDR para a subnet pública. |

Outputs

| Nome | Tipo | Descrição |
|------|------|-----------|
| `vpc_id` | string | ID da VPC criada. |
| `private_subnets` | list(string) | IDs das subnets privadas. |
| `public_subnet` | string | ID da primeira subnet pública criada. |
| `cdir_block` | string | CIDR block da VPC. |

Boas práticas
- Dimensione CIDRs pensando em futuras extensões e conectividade com redes on-premises.
- Configure rotas e NAT gateway/instances conforme a necessidade do projeto.

Comandos úteis

```bash
terraform init
terraform validate
terraform plan -var-file=env/dev.tfvars
```

