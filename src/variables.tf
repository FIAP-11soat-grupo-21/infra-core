# Variáveis para configuração do Application Registry AWS

variable "project_name" {
  description = "Nome do projeto para o Application Registry"
  type        = string
}

variable "project_description" {
  description = "Descrição do projeto"
  type        = string
  default     = "Aplicação para o tech challenge"
}

variable "environment" {
  description = "Ambiente de implantação (ex: dev, staging, prod)"
  type        = string
  default     = "dev"
}

# Variáveis da VPC
variable "vpc_cidr" {
  description = "CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidr" {
  description = "CIDR da sub-rede privada"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_cidr" {
  description = "CIDR da sub-rede pública"
  type        = string
  default     = "10.0.2.0/24"
}

# Variáveis do RDS
variable "db_port" {
  description = "Porta do banco de dados"
  type        = number
}

variable "db_allocated_storage" {
  description = "Armazenamento alocado para o banco de dados em GB"
  type        = number
  default     = 20
}

variable "db_engine" {
  description = "Motor do banco de dados (e.g., mysql, postgres)"
  type        = string
}

variable "db_storage_type" {
  description = "Tipo de armazenamento do banco de dados"
  type        = string
}

variable "db_engine_version" {
  description = "Versão do motor do banco de dados"
  type        = string
}

variable "db_instance_class" {
  description = "Classe da instância do banco de dados"
  type        = string
  default     = "db.t3.micro"
}

variable "db_username" {
  description = "Nome de usuário do banco de dados"
  type        = string
}

# Variáveis do ECS (adicionadas)
variable "ecs_container_name" {
  description = "Nome do container para a definição do ECS"
  type        = string
  default     = "app"
}

variable "ecs_container_image" {
  description = "Imagem do container (ex: repo/image:tag)"
  type        = string
  default     = ""
}

variable "ecs_container_port" {
  description = "Porta exposta pelo container"
  type        = number
  default     = 8080
}

variable "ecs_container_environment_variables" {
  description = "Lista de variáveis de ambiente (name/value) para o container"
  # Usar map(string) para alinhar com o módulo ECS que espera map(string)
  type = map(string)
  default = {}
}

variable "ecs_container_secrets" {
  description = "Lista de segredos para o container (name/valueFrom) - usados para integrar com Secrets Manager"
  type = map(string)
  default = {}
}

variable "ecs_service_name" {
  description = "Nome do serviço ECS"
  type        = string
  default     = "ecs-service"
}

variable "ecs_desired_count" {
  description = "Número desejado de instâncias do serviço ECS"
  type        = number
  default     = 1
}

variable "ecs_network_mode" {
  description = "Modo de rede para a tarefa ECS"
  type        = string
  default     = "awsvpc"
}

variable "ecs_task_cpu" {
  description = "Quantidade de CPU para a tarefa ECS (unidades CPU)"
  type        = string
  default     = "256"
}

variable "ecs_task_memory" {
  description = "Quantidade de memória para a tarefa ECS (MiB)"
  type        = string
  default     = "512"
}

variable "ecs_health_check_path" {
    description = "Caminho para a verificação de integridade do ECS"
    type        = string
    default     = "/"
}

# Variáveis do Secrets Manager
variable "secret_content" {
  description = "Conteúdo do Secret Manager em formato de mapa"
  type        = map(string)
}

# Variáveis do Load Balancer
variable "lb_name" {
    description = "Nome do Load Balancer"
    type        = string
    default     = "myapp-lb"
}

# variáveis do API Gateway
variable "gwapi_name" {
    description = "Nome da API Gateway"
    type        = string
}

variable "gwapi_stage_name" {
    description = "Nome do estágio da API Gateway"
    type        = string
    default     = "prod"
}

variable "gwapi_route_key" {
    description = "Chave da rota para API Gateway (ex: 'ANY /{proxy+}', 'GET /orders')"
    type        = string
    default     = "ANY /{proxy+}"
}

variable "gwapi_auto_deploy" {
    description = "Habilita ou desabilita o auto deploy na API Gateway"
    type        = bool
    default     = true
}

variable "dynamo_name" {
  description = "Nome customizável para a instância DynamoDB criada pelo módulo 'dynamo'. Se vazio, será usado um nome baseado no projeto."
  type        = string
  default     = ""
}

variable "alb_sonarqube_name" {
  description = "Nome do load balancer para a instância Sonarqube"
  type        = string
  default     = "sonarqube"
}

variable "sonarqube_container_name" {
  description = "Nome do container do Sonarqube usado no módulo ECS"
  type        = string
  default     = "sonarqube"
}

variable "sonarqube_container_image" {
  description = "Imagem do container Sonarqube"
  type        = string
  default     = "sonarqube:community"
}

variable "sonarqube_container_port" {
  description = "Porta exposta pelo container Sonarqube"
  type        = number
  default     = 9000
}

variable "sonarqube_service_name" {
  description = "Nome do serviço ECS para Sonarqube"
  type        = string
  default     = "sonarqube"
}

variable "dynamo_hash_key" {
  description = "Nome do partition key (hash key) para a tabela Dynamo"
  type        = string
  default     = "pk"
}

variable "dynamo_hash_key_type" {
  description = "Tipo do partition key para a tabela Dynamo (S|N|B)"
  type        = string
  default     = "S"
}
