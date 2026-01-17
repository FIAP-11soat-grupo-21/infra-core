variable "queue_name" {
  description = "The name of the SQS queue."
  type        = string
  default     = "my-sqs-queue"
}

variable "delay_seconds" {
  description = "The time in seconds that the delivery of all messages in the queue will be delayed."
  type        = number
  default     = 0
}

variable "message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message."
  type        = number
  default     = 345600
}

variable "receive_wait_time_seconds" {
  description = "The time for which a ReceiveMessage call will wait for a message to arrive."
  type        = number
  default     = 0
}

variable "visibility_timeout_seconds" {
  description = "The visibility timeout for the queue."
  type        = number
  default     = 30
}

variable "project_common_tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "allowed_sns_topic_arns" {
  description = "List of SNS Topic ARNs that are allowed to send messages to this queue. If empty, no policy is attached."
  type        = list(string)
  default     = []
}
