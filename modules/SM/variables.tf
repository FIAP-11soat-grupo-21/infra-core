variable "project_name" {
  description = "Nome do projeto para identificação dos recursos"
  type        = string
}

variable "project_common_tags" {
  description = "Tags comuns para todos os recursos do projeto"
  type        = map(string)
  default     = {}
}

variable "secret_name" {
  description = "Nome do Secret Manager"
  type        = string
}

variable "secret_content" {
  description = "Conteúdo do Secret Manager em formato de mapa"
  type        = map(string)
}