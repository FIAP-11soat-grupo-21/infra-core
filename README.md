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

---

## Como integrar a aplicação (repositório separado) com a infraestrutura `infra-core`

Abaixo está um guia prático para que um repositório de aplicação (separado) possa publicar a imagem da aplicação, criar o serviço ECS usando o módulo `ECS-Service` do `infra-core` e expor esse serviço através do API Gateway já provisionado pelo `infra-core`.

Passos resumidos:
1. Build e push da imagem (ECR ou outro registry).
2. No repositório da aplicação, consuma o estado remoto do `infra-core` com `terraform_remote_state` (backend S3/DynamoDB).
3. Crie um Terraform que importe o módulo `ECS-Service` do `infra-core` e passe a imagem criada.
4. Use o output do `ECS-Service` (ex.: `target_group_arn`) para registrar uma rota no API Gateway, via o módulo `API-Gateway-Routes` do `infra-core` ou criando diretamente a integração com VPC Link.

Exemplo detalhado (no repositório da aplicação)

1) Build e push da imagem (exemplo com ECR)

```bash
# ajustar ACCOUNT e região
aws ecr create-repository --repository-name my-app --region us-east-2 || true
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin <ACCOUNT>.dkr.ecr.us-east-2.amazonaws.com
docker build -t my-app:latest .
docker tag my-app:latest <ACCOUNT>.dkr.ecr.us-east-2.amazonaws.com/my-app:latest
docker push <ACCOUNT>.dkr.ecr.us-east-2.amazonaws.com/my-app:latest
```

2) Consumir o state remoto do `infra-core` (mesmo backend S3/DynamoDB usado pelo infra-core)

```hcl
data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "NOME DO BUCKET S3 DO BACKEND"
    key    = "infra-core/terraform.tfstate"
    region = "us-east-2"
  }
}
```

3) Criar o serviço ECS usando o módulo `ECS-Service` do `infra-core`

Ajuste as variáveis de acordo com as entradas reais do módulo. O exemplo assume que o módulo `ECS-Service` aceita `image`, `container_port`, `desired_count` e que recebe `cluster_id`, `subnets` e `security_group_ids` do estado remoto.

```hcl
module "app_service" {
  source = "git::https://github.com/MateusLim4/infra-core.git//modules/ECS-Service?ref=main"

  name           = "my-app"
  image          = "IMAGE NAME:IMAGE TAG"
  container_port = 8080
  desired_count  = 2

  cluster_id         = data.terraform_remote_state.infra.outputs.ecs_cluster_id
  subnets            = data.terraform_remote_state.infra.outputs.private_subnets
  security_group_ids = [data.terraform_remote_state.infra.outputs.alb_security_group_id]
  # ajuste outros inputs do módulo conforme necessário
}
```

4) Expor via API Gateway (usando `API-Gateway-Routes` do `infra-core`)

Este exemplo pressupõe que o `infra-core` exporta `gwapi_id`, `vpc_link_id` e que `module.app_service` expõe `target_group_arn`.

```hcl
module "app_route" {
  source = "git::https://github.com/MateusLim4/infra-core.git//modules/API-Gateway-Routes?ref=main"

  api_id           = data.terraform_remote_state.infra.outputs.gwapi_id
  vpc_link_id      = data.terraform_remote_state.infra.outputs.vpc_link_id
  target_group_arn = module.app_service.target_group_arn

  path   = "/my-app"
  method = "ANY"
}
```

Observações importantes
- Verifique os nomes reais dos outputs expostos pelo `infra-core` (ex.: `ecs_cluster_id`, `private_subnets`, `alb_security_group_id`, `gwapi_id`, `vpc_link_id`, `target_group_arn`) e ajuste os exemplos acima para corresponder aos nomes reais.
- Garanta que ambos os repositórios (aplicação e `infra-core`) usem o mesmo backend remoto (S3 + DynamoDB) ou que você configure corretamente `terraform_remote_state` para apontar para o state do `infra-core`.
- Caso o módulo `ECS-Service` não exporte `target_group_arn`, atualize o módulo para expor esse output para que o API Gateway possa apontar para o ALB/target group.
- Depois de configurar, execute no repositório da aplicação: `terraform init`, `terraform plan -var-file="values.tfvars"` e `terraform apply -var-file="values.tfvars"`.

## Integração adicional: criar Function (Lambda), Database (RDS) e DynamoDB no repositório da aplicação

A abordagem adotada será: a criação dos recursos (Lambda, RDS e DynamoDB) será feita diretamente no repositório da aplicação, instanciando os módulos disponíveis em `infra-core`. O repositório da aplicação deve ainda consumir alguns outputs do `infra-core` (por exemplo subnets, VPC id, security group do ALB, API Gateway id) via `terraform_remote_state` para prover os inputs necessários aos módulos.

Vantagens desta abordagem:
- Código da infraestrutura específica da aplicação (função, tabela, banco) fica junto com o código da aplicação, facilitando deploys e mudanças isoladas.
- Time da aplicação tem controle sobre o ciclo de vida desses recursos.

Requisitos prévios
- O `infra-core` já precisa estar aplicado e com state remoto (S3 + DynamoDB) acessível para o repositório da aplicação.
- O repositório da aplicação precisa de permissões de leitura no bucket S3 do backend.

Exemplo genérico: obtenha outputs do `infra-core` com `terraform_remote_state` (substitua nomes do bucket/key conforme seu backend)

```hcl
data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "NOME_DO_BUCKET_S3_DO_BACKEND"
    key    = "infra-core/terraform.tfstate"
    region = "us-east-2"
  }
}
```

A seguir exemplos práticos de como instanciar cada módulo diretamente no repositório da aplicação.

---

### Lambda (Function)

No repositório da aplicação você deve instanciar o módulo `modules/Lambda` do `infra-core`, apontando `source_path` para o diretório com o código da função no repositório da aplicação. Forneça `subnet_ids` e `security_group_ids` usando valores do `terraform_remote_state`.

```hcl
module "app_lambda" {
  source = "git::https://github.com/MateusLim4/infra-core.git//modules/Lambda?ref=main"

  lambda_name    = "my-app-lambda"
  source_path    = "./lambda"       # caminho relativo no repositório da aplicação
  handler        = "handler.handler"
  runtime        = "python3.9"
  environment    = { ENV = "prod" }

  subnet_ids         = data.terraform_remote_state.infra.outputs.private_subnets
  security_group_ids = [data.terraform_remote_state.infra.outputs.alb_security_group_id]

  # integrar com API Gateway existente (opcional)
  api_id    = data.terraform_remote_state.infra.outputs.gwapi_id
  route_key = "ANY /my-app"

  # permissões opcionais para acessar secrets/dynamo
  secrets_arn           = data.terraform_remote_state.infra.outputs.db_secret_password_arn
  allow_dynamodb_access = true
  dynamo_table_arn      = data.terraform_remote_state.infra.outputs.some_dynamo_table_arn
}
```

Notas:
- O módulo irá zipar o diretório apontado por `source_path` localmente e criar a função dentro da VPC usando os subnets/SGs informados.
- Caso precise do ARN ou nome da função em outros módulos, adicione outputs (`function_arn`, `function_name`) no próprio módulo `modules/Lambda` ou capture `module.app_lambda.*` diretamente.

---

### RDS (Database)

Se a aplicação precisa criar um banco de dados específico, instancie o módulo `modules/RDS` no repositório da aplicação e use `private_subnets` e `vpc_id` do `terraform_remote_state`.

```hcl
module "app_db" {
  source = "git::https://github.com/MateusLim4/infra-core.git//modules/RDS?ref=main"

  project_name        = "my-project"
  project_common_tags = { Project = "my-project" }

  db_port             = 5432
  db_allocated_storage = 20
  db_storage_type     = "gp2"
  db_engine           = "postgres"
  db_engine_version   = "13"
  db_instance_class   = "db.t3.micro"
  db_username         = "appuser"

  private_subnets = data.terraform_remote_state.infra.outputs.private_subnets
  vpc_id          = data.terraform_remote_state.infra.outputs.vpc_id
}

# outputs que você poderá usar na aplicação
output "db_address" {
  value = module.app_db.db_connection
}
output "db_secret_arn" {
  value = module.app_db.db_secret_password_arn
}
```

Notas:
- O módulo `RDS` do `infra-core` já gera um Secret Manager com a senha; utilize o output `db_secret_password_arn` para dar permissões à aplicação.
- Garanta políticas de backup/monitoramento conforme a criticidade do banco.

---

### DynamoDB

Crie a tabela Dynamo diretamente no repositório da aplicação usando o módulo `modules/Dynamo`.

```hcl
module "my_table" {
  source = "git::https://github.com/MateusLim4/infra-core.git//modules/Dynamo?ref=main"

  name      = "my-app-table"
  hash_key  = "id"
  hash_key_type = "S"
  billing_mode  = "PAY_PER_REQUEST"

  project_common_tags = { Project = "my-project" }
}

# outputs úteis
output "table_arn" { value = module.my_table.table_arn }
output "table_name" { value = module.my_table.table_name }
```

Notas:
- O módulo `Dynamo` expõe `table_name`, `table_arn`, `table_stream_arn` (se habilitado) e `policy_arn` (policy para acesso à tabela).
- Caso uma Lambda precise acessar a tabela, passe `dynamo_table_arn` ao módulo `Lambda` e marque `allow_dynamodb_access = true`.

---
