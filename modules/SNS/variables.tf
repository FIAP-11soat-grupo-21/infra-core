variable "topic" {
  description = <<-EOT
Object describing the single topic to create. Fields:
- name: (string) topic name
- display_name: (string) display name for SMS/email
- fifo: (bool)
- content_based_deduplication: (bool)
- kms_master_key_id: (string)
- delivery_policy: (string) JSON delivery policy
- tags: (map(string)) extra tags
- subscriptions: (list(object({ protocol = string, endpoint = string, raw_message_delivery = optional(bool) }))) optional list of subscriptions
EOT
  type = object({
    name                       = optional(string)
    display_name               = optional(string)
    fifo                       = optional(bool)
    content_based_deduplication = optional(bool)
    kms_master_key_id          = optional(string)
    delivery_policy            = optional(string)
    tags                       = optional(map(string))
    subscriptions              = optional(list(object({ protocol = string, endpoint = string, raw_message_delivery = optional(bool) })))
  })
  default = {}
}

variable "project_common_tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
