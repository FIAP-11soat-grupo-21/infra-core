variable "user_pool_name" {
  description = "Nome do Cognito User Pool"
  type        = string
}


variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "allow_admin_create_user_only" {
  description = "Booleano indicando se permite apenas criação de usuário por admin"
  type        = bool
  default     = false
}

variable "auto_verified_attributes" {
  description = "Atributos auto verificados"
  type        = list(string)
  default     = []
}

variable "username_attributes" {
  description = "Atributos usados como username"
  type        = list(string)
  default     = []
}

variable "email_required" {
  description = "Booleano indicado se e-mail é requerido"
  type        = bool
  default     = false
}

variable "name_required" {
  description = "Booleando indicando se booleano é requerido"
  type        = bool
  default     = false
}

variable "generate_secret" {
  description = "Booleano indicado se é para gerar secret para o client"
  type        = bool
  default     = true
}

variable "access_token_validity" {
  description = "Validade do access token em minutos"
  type        = number
  default     = 60
}

variable "id_token_validity" {
  description = "Validade do id token em minutos"
  type        = number
  default     = 60
}

variable "refresh_token_validity" {
  description = "Validade do refresh token em dias"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags adicionais"
  type        = map(string)
  default     = {}
}
