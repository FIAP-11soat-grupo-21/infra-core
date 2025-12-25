output "app_registry_application_tag" {
  description = "Nome do Application Registry criado"
  value       = aws_servicecatalogappregistry_application.app_catalog.application_tag
}