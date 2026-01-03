# Módulo SQS

Descrição

Este módulo cria uma fila SQS principal e uma fila de dead-letter (DLQ). O módulo também declara um tópico SNS opcional que pode ser usado para padrões publish-subscribe / fan-out. O SNS não é obrigatório para o SQS — você pode usar apenas a fila SQS se não precisar de broadcast ou múltiplos subscribers.

Quando usar SNS

- SNS não é obrigatório para usar SQS.
- Use SNS quando precisar de broadcast (um produtor → muitos consumidores), filtragem por atributos, ou integração com outros protocolos (HTTP, Lambda, e-mail etc.).
- Para casos simples (um produtor e poucos consumidores) usar somente SQS é suficiente e mais simples.

Entradas (variáveis esperadas)

> Nota: nomes e tipos baseados nas variáveis usadas pelo módulo.

| Nome | Tipo | Default | Descrição |
|------|------|---------|-----------|
| `queue_name` | string | — | Nome base da fila.
| `delay_seconds` | number | — | Atraso padrão (em segundos) para mensagens enviadas.
| `message_retention_seconds` | number | — | Tempo de retenção das mensagens (em segundos).
| `receive_wait_time_seconds` | number | — | Tempo de long polling (em segundos).
| `visibility_timeout_seconds` | number | — | Timeout de visibilidade (em segundos).
| `project_common_tags` | map(string) | — | Tags aplicadas aos recursos (map de string → string).

Outputs esperados

| Nome | Descrição |
|------|-----------|
| `queue_url` | URL da fila SQS principal.
| `queue_arn` | ARN da fila SQS principal.
| `dead_letter_queue_url` | URL da fila dead-letter.
| `dead_letter_queue_arn` | ARN da fila dead-letter.
| `sns_topic_arn` | ARN do tópico SNS (se o tópico for criado pelo módulo).

Uso (exemplo)

```hcl
module "sqs" {
  source = "../modules/SQS"

  queue_name                 = "app-queue"
  delay_seconds              = 0
  message_retention_seconds  = 1209600
  receive_wait_time_seconds  = 10
  visibility_timeout_seconds = 30

  project_common_tags = {
    Environment = "dev"
    Owner       = "team"
  }
}
```

Assinar a fila SQS no tópico SNS (exemplo)

Se você quiser que o tópico SNS publique na fila SQS (padrão fan-out), adicione uma subscription e ajuste a política de acesso da fila para permitir publicações vindas do SNS:

```hcl
resource "aws_sns_topic_subscription" "sqs_sub" {
  topic_arn            = module.sqs.sns_topic_arn
  protocol             = "sqs"
  endpoint             = module.sqs.queue_arn
  raw_message_delivery = true
}

# Exemplo simplificado de policy para permitir que o SNS publique na fila
data "aws_iam_policy_document" "allow_sns_to_send" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
    actions = ["sqs:SendMessage"]
    resources = [module.sqs.queue_arn]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [module.sqs.sns_topic_arn]
    }
  }
}

resource "aws_sqs_queue_policy" "from_sns" {
  queue_url = module.sqs.queue_url
  policy    = data.aws_iam_policy_document.allow_sns_to_send.json
}
```

Observações importantes

- Para filas FIFO: garanta que tanto o tópico SNS quanto a fila sejam FIFO (terminem com `.fifo`) e que os produtores definam `MessageGroupId` e deduplication quando necessário.
- DLQ (dead-letter queue) é criada pelo módulo; associe a fila principal conforme a configuração do módulo.
- Ajuste as políticas da fila para permitir que o SNS publique nela quando usar a integração SNS → SQS.

Boas práticas

- Use long polling (receive_wait_time_seconds) > 0 para reduzir o número de requests e custo.
- Ajuste visibility timeout para ser maior que o tempo máximo de processamento da mensagem.
- Aumente message_retention_seconds somente se realmente precisar reter mensagens por mais tempo.


Outputs e next steps

- Confirme os nomes exatos dos outputs no módulo (por exemplo `queue_url`, `queue_arn`) e adapte seu código que consome o módulo.
- Se quiser, posso também adicionar a subscription SNS → SQS e a policy de exemplo diretamente no módulo (opcional).
