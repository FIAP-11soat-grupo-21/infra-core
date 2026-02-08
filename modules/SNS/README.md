# SNS module

This module creates one or more AWS SNS topics and optional subscriptions.

Usage example:

```hcl
module "sns" {
  source = "../modules/SNS"

  project_common_tags = {
    Project = "my-project"
  }

  topics = [
    {
      name          = "my-topic"
      display_name  = "My Topic"
      tags = { Env = "dev" }
      subscriptions = [
        { protocol = "sqs", endpoint = "arn:aws:sqs:us-east-1:123:queue-name" }
      ]
    }
  ]
}
```

Outputs:
- topic_arns: map of local topic ids to ARNs
- topic_names: map of local topic ids to names
- subscriptions: map of subscription ids to subscription resources
