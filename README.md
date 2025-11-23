# Infra core

Esse repositório tem por objetivo realizar a criação da infraestrutura base necessária para implementação de nossos microsserviços.

## Tecnologias Utilizadas  
- Terraform
- AWS (Amazon Web Services)

## Estrutura do Repositório
- `modules/`: Contém módulos reutilizáveis do Terraform para diferentes componentes da infraestrutura.
- `environments/`: Contém configurações específicas para diferentes ambientes (desenvolvimento, produção, etc.).
- `src/`: Contém implementação para criação da base de infraestrutura.
- `README.md`: Documentação do repositório.

---

## Como Utilizar
1. Adicione a pasta `src/` um arquivo values.tfvars com as variáveis necessárias para a criação da infraestrutura.`
2. Navegue até a pasta `src/` e execute os comandos do Terraform:
   ```bash
   terraform init
   terraform plan -var-file="values.tfvars"
   terraform apply -var-file="values.tfvars"
   ```
3. Aguarde a conclusão da criação da infraestrutura.
4. Após a criação, você pode verificar os recursos criados na AWS Management Console.
5. Para destruir a infraestrutura criada, utilize o comando:
   ```bash
   terraform destroy -var-file="values.tfvars"
   ```
   
### Exemplo de valores

```hcl
# Global variables
project_name        = "Nome do projeto"
project_description = "Aplicação para o tech challenge"

# VPC variables
vpc_cidr            = "10.0.0.0/16"
private_subnet_cidr = "10.0.1.0/24"
public_subnet_cidr  = "10.0.2.0/24"

# Secrets Variables
secret_content = {
"username" : "SEU USUARIO GITHUB",
"password" : "TOKEN GERADO NO GITHUB"
}

# Load Balancer Variables
lb_name = "NOME DO LOAD BALANCER"

# API Gateway Variables
gwapi_name          = "NOME DO API GATEWAY"
gwapi_stage_name    = "ENDPOINT RAIZ DA API (Ex: 'v1')"
```
