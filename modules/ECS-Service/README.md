# Módulo ECS-Service

## Descrição

Cria uma task definition e um serviço ECS que roda containers; integra-se com ALB para expor o serviço.

## Entradas (inputs)

| Nome | Tipo | Obrigatório | Descrição |
|------|------|:----------:|----------|
| project_common_tags | map(string) | Sim | Tags comuns do projeto |
| cluster_id | string | Sim | ID do cluster ECS |
| ecs_security_group_id | string | Sim | Security Group associado às tasks |
| task_execution_role_arn | string | Sim | ARN da role usada pelo ECS para executar tarefas (execution role) |
| task_role_arn | string | Não | ARN da task role (role que os containers assumem para chamadas AWS). Se vazio, o módulo cria uma role internamente e a expõe como output |
| cloudwatch_log_group | string | Sim | CloudWatch Log Group usado pelos containers |
| private_subnet_ids | list(string) | Sim | Subnets privadas onde as tasks serão executadas |
| registry_credentials_arn | string | Não | ARN do Secret com credenciais do registry |
| ecs_container_name | string | Sim | Nome do container na task definition |
| ecs_container_image | string | Sim | Imagem do container (ex: repo/image:tag) |
| ecs_container_port | number | Sim | Porta exposta pelo container |
| ecs_container_environment_variables | map(string) | Não | Variáveis de ambiente para o container |
| ecs_container_secrets | map(string) | Não | Segredos a injetar no container |
| ecs_desired_count | number | Não | Número desejado de instâncias do serviço |
| ecs_task_cpu | string | Não | CPU da task (unit) |
| ecs_task_memory | string | Não | Memória da task (MiB) |
| ecs_service_name | string | Não | Nome do serviço ECS |
| alb_target_group_arn | string | Não | ARN do target group do ALB para registrar as tasks |
| alb_security_group_id | string | Não | ID do SG do ALB (para configurar regras) |

## Saídas (outputs)

| Nome | Descrição |
|------|-----------|
| service_id | ID do serviço ECS (se o módulo criar) |
| task_definition_arn | ARN da task definition (se o módulo criar) |
| task_role_arn | ARN da task role usada pela task (pode ser a role fornecida ou a role criada internamente) |

## Integração com Dynamo (passo-a-passo)

Quando usar o módulo `modules/Dynamo` e quiser que seus containers ECS acessem a tabela:

1) Crie uma `aws_iam_role` para ser a task role e defina a assume role policy adequada (principal = ecs-tasks.amazonaws.com).
2) Anexe a policy criada pelo módulo Dynamo (`module.dynamo.policy_arn`) a essa role.
3) Ao instanciar este módulo ECS, passe `task_role_arn = aws_iam_role.ecs_task_role.arn`.
4) Adicione `module.dynamo.table_name` como variável de ambiente (`ecs_container_environment_variables`) para que a aplicação saiba qual tabela usar.

Exemplo mínimo (no root module):

```
# role da task
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_attach_dynamo" {
  role = aws_iam_role.ecs_task_role.name
  policy_arn = module.dynamo.policy_arn
}

# instancia o módulo ECS
module "ecs_api" {
  source = "../ECS-Service"
  project_common_tags = local.project_common_tags
  project_name = var.project_name
  cluster_id = module.ecs_cluster.cluster_id
  private_subnet_ids = module.vcp.private_subnets
  registry_credentials_arn = module.ghcr_secret.secret_arn
  ecs_container_name = var.ecs_container_name
  ecs_container_image = var.ecs_container_image
  ecs_container_port = var.ecs_container_port
  ecs_container_environment_variables = {
    DDB_TABLE_NAME = module.dynamo.table_name
  }
}
```

## Se o módulo criar a `task role` internamente

- Se você NÃO fornecer `task_role_arn` ao instanciar o módulo, o módulo `ECS-Service` cria uma `aws_iam_role` internamente e expõe a ARN desta role via output `module.ecs.task_role_arn`.
- Recomendação: anexe a policy do Dynamo externamente ao role criado para manter responsabilidades separadas. Abaixo segue um exemplo de como fazer isso extraindo o nome da role a partir do ARN retornado pelo módulo e depois usando `aws_iam_role_policy_attachment`:

```
# instancia o ECS sem fornecer task_role_arn (role será criada internamente)
module "ecs" {
  source = "./modules/ECS-Service"
  cluster_id = aws_ecs_cluster.main.id
  ecs_security_group_id = aws_security_group.ecs.id
  task_execution_role_arn = aws_iam_role.ecs_execution_role.arn
  private_subnet_ids = var.private_subnet_ids
  ecs_container_name = "app"
  ecs_container_image = "meu-registro/minha-imagem:latest"
  ecs_container_port = 8080
}

# depois (pode ser no mesmo root module) anexa a policy do dynamo à role criada pelo módulo
locals {
  ecs_task_role_name = length(module.ecs.task_role_arn) > 0 ? split("/", module.ecs.task_role_arn)[1] : ""
}

resource "aws_iam_role_policy_attachment" "attach_dynamo_to_ecs_role" {
  count = local.ecs_task_role_name != "" ? 1 : 0
  role       = local.ecs_task_role_name
  policy_arn = module.dynamo.policy_arn
}
```

## Observações sobre rede

- Este módulo configura `assign_public_ip = false` nas tasks (assume subnets privadas). Se essas subnets não tiverem egress para a Internet, garanta:
  - NAT Gateway/Instance; ou
  - `aws_vpc_endpoint` do tipo Gateway para DynamoDB (recomendado para evitar NAT).

- Autorização para acessar DynamoDB depende da `task_role_arn` (role da task). A `task_execution_role_arn` é usada apenas pelo agente do ECS para puxar imagens e logs.

## Notas finais

- Verifique a configuração de security groups entre ALB e tasks para permitir tráfego na porta correta.
- Se desejar auto-scaling ou integração com Service Discovery, expanda este módulo conforme necessário.
