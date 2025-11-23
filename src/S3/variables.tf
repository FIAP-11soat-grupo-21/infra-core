// filepath: c:\Users\mateu\GolandProjects\infra\S3\variables.tf

variable "bucket_name" {
  description = "Nome próprio do bucket S3. Deve ser único globalmente e não deve ser o nome do projeto"
  type        = string
}

variable "acl" {
  description = "ACL do bucket"
  type        = string
  default     = "private"
}

variable "force_destroy" {
  description = "Se true, permite destruir o bucket mesmo que contenha objetos"
  type        = bool
  default     = false
}

variable "project_common_tags" {
  description = "Tags comuns para todos os recursos do projeto"
  type        = map(string)
  default     = {}
}

variable "enable_versioning" {
  description = "Habilita versionamento no bucket"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Habilita criptografia server-side no bucket"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "ID da chave KMS a ser usada (opcional). Se vazio, será usado AES256"
  type        = string
  default     = ""
}

variable "block_public_acls" {
  description = "Bloquear ACLs públicos"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Bloquear políticas públicas"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Ignorar ACLs públicos"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Restringir buckets públicos"
  type        = bool
  default     = true
}

variable "enable_lifecycle_rule" {
  description = "Habilita regra de ciclo de vida que expira objetos após X dias"
  type        = bool
  default     = false
}

variable "lifecycle_days" {
  description = "Número de dias para expiração dos objetos quando a regra de lifecycle estiver habilitada"
  type        = number
  default     = 30
}

