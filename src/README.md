# Infra - Terraform (pasta src)

Este diretório (`src/`) contém a configuração principal do Terraform que orquestra os módulos locais em `modules/` para criar a infraestrutura do projeto.

Este README descreve o que será criado, quais módulos existem, variáveis importantes, outputs e instruções rápidas para executar os comandos (exemplos em PowerShell).

---

## Visão geral dos módulos

A estrutura do repositório contém módulos em `modules/` que são consumidos a partir de `src/main.tf`. Abaixo está uma lista das responsabilidades de cada módulo presente no repositório:

- APP-Registry: Registra metadados da aplicação (tags/registry). Fornece tags compartilhadas usadas por outros módulos.
- VPC: VPC principal, subnets públicas/privadas e recursos de rede associados.
- SM (Secrets Manager): Criação de segredos (ex.: ghcr credentials) e ARN para uso por outros serviços.
- ECS-Cluster: Cluster ECS (ECS cluster) e recursos relacionados (roles, logs). Usa subnets e secrets.
- ALB: Application Load Balancer (internal/external), listeners e target groups.
- API-Gateway: API Gateway configurada para se integrar com ALB (rotas, stages, deployment).
- API-Gateway-Routes: Rotas e integrações específicas do API Gateway.
- Lambda: Funções Lambda (quando aplicável para integrações ou backends).
- Dynamo: Tabelas DynamoDB (se usadas pelos serviços).
- RDS: Instância de banco de dados relacional (RDS) e seus parâmetros.
- S3: Buckets S3 para armazenamento (logs, artefatos, etc.).
- Cognito: User Pool e recursos de autenticação (se aplicável).
- ECS-Service: Serviço ECS (tasks, serviço, autoscaling). 

> Observação: alguns módulos podem não estar sendo usados por `src/main.tf` atual; verifique `src/main.tf` e os módulos para confirmar o que será criado no seu caso.


## Principais recursos que serão criados

Dependendo das variáveis e do que estiver habilitado nos módulos, a execução padrão criará ao menos os seguintes recursos:

- Rede: VPC, subnets públicas e privadas, tabelas de rota e gateways (módulo `VPC`).
- Registro de aplicação / tags: recurso para centralizar tags do projeto (módulo `APP-Registry`).
- Secrets Manager: segredo contendo credenciais (por exemplo `-ghcr`) com ARN exportado (módulo `SM`).
- Cluster ECS e serviços: cluster ECS, definições de task e serviço (módulos `ECS-Cluster` e `ECS-Service`).
- Application Load Balancer: ALB interno/externo, listeners, target groups (módulo `ALB`).
- API Gateway: API REST/HTTP (dependendo da implementação) integrada ao ALB e stages (módulo `API-Gateway` + `API-Gateway-Routes`).
- Persistência: DynamoDB tables e/ou RDS instance conforme módulos habilitados.
- Armazenamento: Buckets S3 necessários para a aplicação ou logs.
- Autenticação: Cognito UserPool e Client (se configurado).
- Lambdas: Funções e roles associadas (quando presentes nos módulos).


## Entradas principais (variáveis)

O arquivo `src/variables.tf` declara as variáveis usadas pelo conjunto de módulos. Alguns exemplos importantes (ver `variables.tf` para lista completa):

- `project_name` - nome do projeto (usado para nomear recursos)
- `environment` - ambiente (ex.: dev/staging/prod)
- `vpc_cidr`, `private_subnet_cidr`, `public_subnet_cidr` - ranges de rede
- `lb_name` - nome do load balancer
- `gwapi_name` - nome da API Gateway
- `secret_content` - conteúdo do segredo a ser criado

Valores recomendados e sensíveis devem ser passados via arquivo de variáveis (ex.: `values.tfvars`) ou via variáveis de ambiente, não commitar valores sensíveis no repositório.


## Outputs

Os módulos normalmente expõem outputs (ver `modules/*/output.tf`) como IDs, ARNs e endpoints. Exemplos típicos:

- `vpc_id`, `private_subnets`, `public_subnets`
- `alb_arn`, `alb_dns_name`, `target_group_arn`
- `registry_secret_arn` (ARN do segredo no Secrets Manager)
- `api_gateway_url` ou `api_invoke_url`
- Endpoints de RDS, nomes de tabelas Dynamo, nomes de buckets S3


## Pré-requisitos

- Terraform instalado (versão compatível com a configuração do projeto).
- AWS CLI configurado com credenciais e região apropriadas (perfil AWS configurado ou variáveis de ambiente `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`).
- Permissões IAM suficientes para criar os recursos listados.


## Comandos rápidos (PowerShell)

Abra o PowerShell e vá para a pasta `src`:

```powershell
Set-Location -Path "C:\Users\mateu\GolandProjects\infra-core\src"

# Inicializar o diretório Terraform
terraform init

# Formatar o código (opções: recursivo ou por módulo)
terraform fmt -recursive

# Verificar o plano usando o arquivo de variáveis (ex.: values.tfvars)
terraform plan -var-file="values.tfvars"

# Aplicar (siga as mensagens e confirme)
terraform apply -var-file="values.tfvars"

# Aplicar sem prompt (usar com cuidado)
# terraform apply -auto-approve -var-file="values.tfvars"
```


## Dicas e notas de operação

- Sempre executar `terraform init` após alterar providers ou módulos locais.
- Use `terraform validate` para checar a sintaxe e elementos básicos de configuração.
- Para desenvolvimento, utilize workspaces (`terraform workspace new dev`) para isolar estados por ambiente.
- Tenha cuidado com recursos que envolvem custos (RDS, NAT gateways, ALBs). Remova/limpe recursos com `terraform destroy` quando não precisar mais.


## Contrato mínimo (inputs/outputs/erros)

- Inputs: `values.tfvars` (ou variáveis passadas via CLI), credenciais AWS e região.
- Outputs: IDs/ARNs/endpoints dos recursos criados (conforme `outputs.tf` dos módulos).
- Erros esperados: falta de credenciais AWS, conflito de nomes ou CIDR overlap, limites de conta (quotas).